# Install Claude Desktop's mysql-local MCP Server With Claude

This file is written for a Claude session that has direct terminal and file access to **this computer** — for example, Claude Code running locally on the machine that also runs Claude Desktop. It will not work from a sandboxed or remote session (including a Cowork session bridged to this computer through the device tools), because those sessions cannot reach Claude Desktop's application settings folder. If that describes the current session, stop and tell the user so, then point them to the manual steps in `README.md` instead.

The person setting up this project should not need to run terminal commands themselves, and should never need to paste a database password into this conversation.

## Instructions for Claude

Help the user prepare this computer to run the `mysql-local` MCP server for Claude Desktop. Perform the technical checks and configuration steps yourself instead of asking the user to copy terminal commands.

Follow this process:

1. Check the operating system and processor architecture.
2. Run `node --version` and `npx --version`.
3. If Node.js 20 or newer and `npx` are already available, do not reinstall them. Report the detected versions and continue to step 7.
4. If Node.js is missing or older than version 20, explain in one short sentence that Node.js LTS is required and that installing it will modify the computer.
5. Ask for approval when the app or operating system requires it. Do not try to bypass an approval prompt.
6. Install the current Node.js LTS release using a trustworthy package manager already present on the computer:
   - On macOS, prefer Homebrew if `brew` is already installed.
   - On Windows, prefer `winget` if it is available.
   - On Linux, use the existing distribution package manager only if its candidate Node.js version is 20 or newer.
   - Do not install a new package manager, run a remote `curl | sh` script, or use `sudo` without explaining the need and receiving explicit user approval.
   - If no suitable package manager is available, direct the user to the official Node.js LTS installer at https://nodejs.org/en/download and give only the minimum clicks needed.
7. Verify the completed installation by running `node --version`, `npx --version`, and the operating system's command for locating `npx` (`which npx` on macOS/Linux or `where.exe npx` on Windows). Keep the full path — you'll need it.
8. Verify that `@benborla29/mcp-server-mysql@2.0.9` is resolvable from npm (for example `npm view @benborla29/mcp-server-mysql@2.0.9 version`) without starting the server or requesting database credentials.
9. In this repository, create two files if they don't already exist:
   - `bin/mysql-local-mcp.sh` (macOS/Linux) or `bin/mysql-local-mcp.cmd` (Windows) — a small wrapper script that loads credentials from a local, untracked env file and then execs the MCP server. Use the full `npx` path from step 7 inside the wrapper. Make the script executable (`chmod +x` on macOS/Linux).
   - `mysql-local.env.example` — a template with the five variable names (`MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASS`, `MYSQL_DB`) and empty values, committed to the repo so future coworkers know what to fill in.
   Add `mysql-local.env` (no `.example` suffix) to `.gitignore` if it isn't already ignored — this is the real, untracked file that will hold the actual credentials.
10. If `mysql-local.env` does not already exist, copy `mysql-local.env.example` to `mysql-local.env`. Do not fill in any values yourself and do not ask the user to say them out loud or paste them into this chat. Tell the user the exact file path and ask them to open it directly in a text editor on this computer and type the five values Mike gave them into the matching blank fields, then save. This file never needs to be shown to Claude — that's what makes it the secure place to enter credentials.
11. Locate Claude Desktop's MCP configuration file for the detected OS:
    - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
    - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
    - Linux: `~/.config/Claude/claude_desktop_config.json`
    If Claude Desktop has never been opened, the folder may not exist yet — ask the user to open Claude Desktop once first, then continue.
12. Read the existing file if present and parse it as JSON. If it doesn't exist, start from `{}`. Preserve every existing key and every other entry under `mcpServers` — only add or replace the `mysql-local` entry. Point its `command` at the full path to the wrapper script from step 9, with no `args` and no `env` block — because the wrapper script itself loads `mysql-local.env`, the database password never has to appear in this JSON file at all.
13. Save the file, preserving valid JSON formatting. Do not add `ALLOW_INSERT_OPERATION`, `ALLOW_UPDATE_OPERATION`, or `ALLOW_DELETE_OPERATION` anywhere in this setup.
14. Once the user confirms they've saved their five values into `mysql-local.env`, tell them to fully quit Claude Desktop — not just close its window — and reopen it, then check **Settings > Developer** to confirm `mysql-local` is running.
15. Offer to help them run the read-only connection check from `README.md` once they confirm the server is running.

Stop and clearly explain the next manual action if an installer, administrator password, device policy, or missing package manager prevents you from continuing safely. Never write real database credentials into `README.md`, `claude_desktop_config.json`, any tracked repository file, or this chat — only the user should type them, directly into `mysql-local.env`.
