# Zorakle Analytics Assistant Instructions

These instructions apply to every data question asked from this repository. The user should be able to ask a business question directly without supplying a separate starter prompt.

## Default behavior

- Use the `mysql-local` MCP connector for all database work.
- If `mysql-local` is unavailable, tell the user the connection is not configured and direct them to `README.md`. Do not silently use another database connector or guess an answer.
- Give the direct answer first, followed by a short explanation of what was counted.
- Show SQL only when the user asks for it.

## Safety rules

- Treat the database as read-only. Run only `SELECT`, `SHOW`, `DESCRIBE`, `EXPLAIN`, or `WITH ... SELECT` statements.
- Never run `INSERT`, `UPDATE`, `DELETE`, `REPLACE`, `TRUNCATE`, `ALTER`, `DROP`, `CREATE`, `GRANT`, `REVOKE`, stored procedures, or administrative commands.
- Never reveal credentials, connection strings, environment variables, access keys, tokens, or configuration-file contents.
- Return aggregate results by default. Do not return names, email addresses, phone numbers, or other row-level personal data unless the user explicitly requests authorized detail.

## Validation rules

- First verify the selected server and database without showing credentials.
- Inspect `information_schema` for relevant tables and columns before writing a business query. Do not guess schema names.
- If the expected `prospects` table is missing, tell the user the selected database appears incomplete or incorrect and stop. Do not silently substitute another table.
- Use the `zorakle-new` and `zoracle` repositories for business-logic context when available, but treat the live database schema as the source of truth for current columns.
- Both repositories read from and write to the same shared database — a table's owning codebase (noted below) is about which app's business logic populates it, not a separate schema. `information_schema.TABLE_NAME` lookups do not need a repo qualifier.
- Prefer `information_schema.STATISTICS` (or `SHOW INDEX FROM <table>`) over guessing which columns are indexed, especially on `prospects`, `match_referrals`, and `eclipse_profiles`, which carry composite indexes added specifically for analytics queries (see "Useful indexes" below) — filtering and grouping on those columns avoids full scans on tables that can be tens of millions of rows.

## Zorakle business mappings

- `zorakle-new` is the admin portal. `zoracle` delivers assessments and generates scores and matches.
- `accounts` is the tenant/customer table. Prefer `accounts.new_portal_type` over the legacy `accounts.type` field.
- Common `new_portal_type` values are `franchisor`, `broker`, `enterprise`, `broker_group`, and `affiliate`.
- `accounts.is_baby_zor = 1` means an emerging/BabyZor franchisor.
- Join `prospects.account_id` to `accounts.id`.
- A completed main prospect assessment means `prospects.completed_at IS NOT NULL`.
- A completed CQ means `prospects.cq_completed_at IS NOT NULL`. Keep it separate from main completion unless the user asks to combine them.
- Exclude prospects where `deleted_at IS NOT NULL` unless the user explicitly asks for deleted data.
- `assessment_scores` has one row per `prospect_id` and contains calculated scores. Its `created_at` may be used only as a clearly labeled proxy when `prospects` is unavailable; it is not the authoritative completion timestamp.
- `answers` has many rows per prospect. Join `answers.prospect_id` to `prospects.id` and use `COUNT(DISTINCT prospects.id)` for prospect totals.
- `assessments` describes assessment definitions; join `answers.assessment_id` to `assessments.id`.
- `assessment_links` identifies share/source links; join `prospects.assessment_link_id` to `assessment_links.id`.
- `eclipse_profiles` stores company match results by `prospect_id` and matched `account_id`.
- `match_referrals` stores broker referrals: `prospect_id` is the candidate, `broker_id` is the referring account, and `company_id` is the destination account.
- `prospects.research_group` values are `1` = A/high performer, `2` = B/mid performer, and `3` = C/low performer. Null generally means an ordinary prospect.
- `zor_assessments` is an account/franchisor onboarding audit in `zorakle-new`, not a prospect assessment completion.
- `account_features` is a presence table, not a flag table: one row per `(account_id, feature_name)` means that feature is enabled for that account — there is no boolean/value column, so "is feature X on" is `EXISTS (... WHERE account_id = ? AND feature_name = 'X')`, not a column read.
- `broker_groups` (its own table, created by `zorakle-new`) has columns `id`, `broker_group_id`, `account_id`, `status`, and soft deletes — `broker_group_id` here does **not** self-reference `broker_groups.id`; it is a separate grouping key. This is distinct from `accounts.broker_group_id` (added later, directly on `accounts`), which links a broker account to its parent broker group account. Confirm foreign keys via `information_schema.KEY_COLUMN_USAGE` before joining either — the naming overlap is a known trap.
- Prospect research-group tagging exists in two parallel places that are not guaranteed to agree: the single `prospects.research_group` integer (1/2/3, described above) and a normalized set — `research_groups` (id, name, description), `account_research_group` (account_id, research_group_id, sort_order), and `prospect_research_group` (prospect_id, research_group_id, account_id). If a query needs research-group data, check which of the two the user's question actually depends on, and note in the answer which source was used.

## Marketing & lifecycle columns

- **Funnel/engagement on `prospects`**: `started_at` (assessment begun), `progress_percent` and `cq_progress_percent` (0–100, partial completion), `abandoned_at`, and `completed_at`/`cq_completed_at` (terminal states). Use `started_at`/`abandoned_at` for drop-off and time-to-complete analysis rather than inferring progress from `created_at` alone.
- **Unsubscribes**: `prospects.unsubscribed_from_reminders` is a boolean opt-out flag; `unsubscribe_logs` (`prospect_id`, `email`, `unsubscribe_type`, `method`, `created_at`) is the event log — use the log for "when/why did they unsubscribe" questions and the flag for current suppression status.
- **Email send/engagement logs**: activity is split across several per-flow tables rather than one — `prospect_schedule_email_logs`, `zee_schedule_email_logs`, `setup_email_logs`, `checkout_email_logs`, and `mail_logs` (more general). Check `information_schema` for each table's actual columns before assuming they share a shape; do not silently union them without confirming the user wants combined send volume across flows.
- **HubSpot (owned by `zoracle`)**: `hubspot_connects` (per-user OAuth connection), `hubspot_deals` (`hubspot_connect_id`, `hs_object_id`), and `hubspot_deals_prospects` (pivot: `hubspot_deal_id` ↔ `prospect_id`) — use this path for "which prospects are tied to a HubSpot deal" questions.
- **Affiliate program (owned by `zorakle-new`)**: `accounts.is_affiliate = 1` flags an affiliate account; `affiliate_settings` (`account_id`, `cut_percentage`, `cut_length`, `coupon_code`, `coupon_percentage`, `trial_period`) holds terms per affiliate; `affiliate_payments` (`account_id`, `amount`, `date_paid_for`) is the payout ledger; `affiliate_invites` tracks the invite flow. Attribution of a signup to an affiliate typically runs through the coupon/link on the account, not a direct FK — verify the actual linking column via `information_schema` for the specific question asked.
- **`assessment_links`** (share/source links) also carries `source`, `source_type`, `scope` (default `'user'`), and an `archive` flag — useful for campaign/channel attribution. A newer `assessment_link_assessment` table is a polymorphic pivot (`entity_id`, `entity_type`, `assessment_id`, `sort_order`); a link can now point to multiple assessments, so don't assume one assessment per link when the polymorphic table is present. `assessment_links` also has soft deletes — apply the same `deleted_at IS NULL` default as elsewhere unless asked otherwise.
- **`accounts_cache`** is a denormalized billing/progress snapshot per account (`cost`, `product_name`, `billing_interval`, `billing_status`, `amount_past_due`, `audit_progress`, response-progress fields). It's convenient for quick account-level billing questions without joining Stripe (`subscriptions`/`products`/`prices`) tables, but it's a cache — flag to the user that figures may lag the live billing tables if precision matters.

## Legacy & demo/test data

- `accounts.is_demo = 1` marks a demo account — check for it (in addition to any name-based heuristics) whenever excluding non-production accounts, per the demo/test exclusion rule below.
- Some accounts predate the current schema and are bridged from a `legacy_accounts` table (with matching `LegacyAccount`/`LegacyContact`/`LegacyPayment` concepts) rather than being fully represented in `accounts`. `accounts.migration_date` and `accounts.old_account_id` indicate a migrated legacy account; `legacy_accounts.migration_ready` and `legacy_accounts.disable_migration` describe migration state, not business status — don't treat them as account health/activity signals. For legacy accounts, contact and payment history may need to come from the legacy tables rather than their `zorakle-new` equivalents.
- A `test_contacts` table exists for excluding known test/QA contacts; check whether it's populated and how it's keyed (it may just be a set of ids to anti-join against) before assuming it applies to a given question.

## Useful indexes

- `prospects`: composite indexes on `(account_id)`, `(account_id, completed_at)`, `(account_id, abandoned_at)`, `(account_id, completed_at, research_group)`, and `(assessment_link_id)`. Filtering/grouping by `account_id` plus one of these date or status columns together (rather than filtering on the date column alone) uses the index.
- `match_referrals`: indexes on `prospect_id`, `broker_id`, `company_id`, `status`, and the composite `(broker_id, company_id)` and `(company_id, broker_id, created_at)`. Lead with `broker_id`/`company_id` when querying referral volume or funnel by broker or destination company.
- `eclipse_profiles`: composite indexes on `(account_id, ranking)`, `(account_id, overall_fit_percent)`, `(account_id, prospect_id)`, and `prospect_id`. Rank/fit-percent queries scoped by account should filter on `account_id` alongside the sort column.

## Analysis rules

- After one-to-many joins, count distinct prospect IDs so answers, matches, or referrals do not inflate totals.
- State the exact date range, timezone, filters, exclusions, and counting unit.
- Interpret “last six months” as a rolling six-month window; distinguish it from six complete calendar months.
- When the user requests “unique people,” explain whether the result counts prospect records or normalized distinct email addresses.
- Ask whether demo/test accounts should be excluded when it would materially change a business total — check both `accounts.is_demo = 1` and, if relevant to the question, `test_contacts`.
- When a marketing question implies opted-in/engaged audiences (email campaigns, outreach), exclude `prospects.unsubscribed_from_reminders = 1` by default and say so, unless the user is specifically asking about unsubscribes.
- Sanity-check important totals with a second query, such as monthly subtotals or `COUNT(*)` versus `COUNT(DISTINCT ...)`.

