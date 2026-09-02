# Zorakle Analytics MCP Setup

Use ChatGPT/Codex or Claude Desktop with the `mysql-local` MCP server to ask plain-English, read-only questions about Zorakle's MySQL data.

No API key is required. You need either the ChatGPT desktop app or Claude Desktop, Node.js, and read-only database credentials from Mike.

> **Keep credentials private:** Never put a database password in this repository, a ChatGPT prompt, Slack, email, or a screenshot. Add it only to the MCP server's private environment-variable settings.

> **Internal tooling.** This repository is for Zorakle staff only. It documents how to reach an internal database and describes the Zorakle data model. Do not fork it to a public account, republish it, or share it outside the company.

## What you'll do

1. Install the desktop app you'll use — ChatGPT/Codex **or** Claude Desktop.
2. Download this repository.
3. Set up the `mysql-local` MCP server (let the assistant do it, or follow the manual steps).
4. Run the read-only connection check, then ask data questions directly.

Follow the section for the app you picked. You do not need both.

## ChatGPT/Codex setup

ChatGPT users can let Codex perform most of the setup or follow the manual instructions.

### Before choosing a ChatGPT setup path

Everyone must complete these first two steps.

#### 1. Install ChatGPT

If ChatGPT is not already installed:

1. Go to the [official ChatGPT download page](https://chatgpt.com/download/).
2. Download the desktop app for macOS, Windows, or Linux.
3. Install it, open it, and sign in with your ChatGPT account.
4. Select **Codex** from the app's top-left menu.

The desktop app is required for this local setup. ChatGPT on the web does not read MCP configuration from your computer. See the [official desktop app guide](https://learn.chatgpt.com/docs/app) for more help.

#### 2. Download this repository

Choose one option.

##### Download method 1: ZIP (easiest)

1. Open this repository on GitHub.
2. Select **Code** > **Download ZIP**.
3. Unzip the download somewhere easy to find.
4. In ChatGPT, open **Codex**, select **Open folder**, and choose the unzipped folder.

##### Download method 2: Git

Open Terminal on macOS/Linux or PowerShell on Windows and run:

```bash
git clone https://github.com/mkidushim-zorakle/analytics-ai.git
cd analytics-ai
```

Then open the `analytics-ai` folder in ChatGPT's Codex workspace.

### Choose one ChatGPT setup path

You only need to follow **one** of these paths:

| Setup path | Best for | What to do |
| --- | --- | --- |
| **Path A: Let Codex help** | Recommended for most coworkers | Send Codex one message and approve the installation when prompted. |
| **Path B: Manual setup** | People comfortable following technical steps | Install Node.js and configure the MCP server yourself. |

### Path A — Easiest: let Codex help

Open the downloaded repository folder in **Codex**, start a task, and send this message:

```text
Follow INSTALL_WITH_CODEX.md and set up this computer for me.
```

Codex will:

1. Check whether Node.js is already installed.
2. Install Node.js when possible.
3. Verify the installation.
4. Walk you through adding the MCP server.
5. Help test the database connection.

The user may need to select **Approve** for the Node.js installation. When Codex asks for database credentials, enter them directly in ChatGPT's MCP settings — never paste them into the task.

**If you choose Path A, stop here and follow Codex's instructions. Do not also complete Path B.**

### Path B — Manual setup

Use the steps below only if you prefer to perform the setup yourself.

#### Manual step 1: Install Node.js

The MCP server runs through Node.js. Install the current [Node.js LTS release](https://nodejs.org/en/download) if it is not already installed.

Confirm the installation:

```bash
node --version
npx --version
```

If both commands print version numbers, continue. Node.js 20 or newer is required.

Find the full path to `npx`:

**macOS/Linux**

```bash
which npx
```

**Windows PowerShell**

```powershell
where.exe npx
```

Keep the path that command prints. You will use it in the next step.

#### Manual step 2: Get read-only database credentials

Ask Mike for these values through the company password manager or another approved secure channel:

- MySQL host
- MySQL port (normally `3306`)
- Database name
- Read-only database username
- Read-only database password

The database user must have `SELECT` access only. Do not use the Laravel application's production credentials.

#### Manual step 3: Add the MCP server to ChatGPT

In the ChatGPT desktop app:

1. Open **Settings** > **MCP servers**.
2. Select **Add server**.
3. Set the name to `mysql-local`.
4. Choose **STDIO**.
5. Set **Command** to the full `npx` path from manual step 1.
6. Add these arguments in order:
   - `-y`
   - `@benborla29/mcp-server-mysql@2.0.9`
7. Add the following environment variables, replacing the example values with the credentials Mike supplied:

| Variable | Value |
| --- | --- |
| `MYSQL_HOST` | `<read-only database host>` |
| `MYSQL_PORT` | `3306` |
| `MYSQL_USER` | `<read-only username>` |
| `MYSQL_PASS` | `<read-only password>` |
| `MYSQL_DB` | `<database name>` |

Do **not** add `ALLOW_INSERT_OPERATION`, `ALLOW_UPDATE_OPERATION`, or `ALLOW_DELETE_OPERATION`. The connector is read-only by default, and the database account must provide a second layer of read-only protection.

8. Save the server.
9. Select **Restart**. If that option does not appear, quit and reopen ChatGPT.

ChatGPT downloads and starts the pinned MCP server package automatically when needed. You do not need to run it continuously in a separate terminal.

#### Manual step 4: Verify the connection

Open a new Codex task in this folder. Type `/mcp` and confirm that `mysql-local` is enabled, then paste:

```text
Use mysql-local to run a read-only connection check. Return the server hostname,
port, selected database, database version, and whether the tables accounts,
prospects, and assessment_scores exist. Do not show credentials.
```

A healthy full-data connection should find `accounts`, `prospects`, and `assessment_scores`. If `prospects` is missing, stop and ask Mike to verify the database name and user permissions.

#### Manual step 5: Ask a data question

Open a new Codex task in this repository and ask your question directly. Codex automatically reads [AGENTS.md](./AGENTS.md), so there is no starter prompt to copy.

For example:

```text
How many prospects completed an assessment in the last six months? Break the
result down by month and account type.
```

The repository instructions tell ChatGPT how to query safely, use the correct Zorakle business definitions, avoid inflated counts, and protect sensitive data.

## Claude Desktop setup

Use these steps if you want to use Claude Desktop instead of ChatGPT/Codex.

### 1. Install Claude Desktop

1. Go to the [official Claude download page](https://claude.ai/download).
2. Download and install Claude Desktop for your operating system.
3. Open Claude Desktop once and sign in. Opening it creates the local configuration folder.

Claude Desktop — not Claude in a web browser, and not a sandboxed or remote Claude session — is required for this local MCP setup.

### 2. Download this repository

Choose one method:

- On GitHub, select **Code** > **Download ZIP**, then unzip the download somewhere easy to find.
- Or clone it with Git:

```bash
git clone https://github.com/mkidushim-zorakle/analytics-ai.git
cd analytics-ai
```

Keep this README open for the remaining steps.

### Choose one Claude setup path

You only need to follow **one** of these paths:

| Setup path | Best for | What to do |
| --- | --- | --- |
| **Path A: Let Claude help** | Recommended when you have a Claude session with terminal access to this computer, such as Claude Code running locally | Send Claude one message and type your database values into a local file it creates for you. |
| **Path B: Manual setup** | Anyone, including plain Claude Desktop with no terminal access | Install Node.js and configure the MCP server yourself. |

### Path A — Let Claude help

This path needs a Claude session that can run commands and edit files directly on this computer — for example, Claude Code running locally. It does **not** work from a sandboxed or remote session (including a Cowork session bridged to this computer through device tools), because those sessions cannot reach Claude Desktop's application settings folder.

Open the downloaded repository folder in that session, start a task, and send this message:

```text
Follow INSTALL_WITH_CLAUDE.md and set up this computer for me.
```

Claude will:

1. Check whether Node.js is already installed.
2. Install Node.js when possible.
3. Verify the installation.
4. Create a small wrapper script (`bin/mysql-local-mcp.sh` or `.cmd`) and a local, git-ignored `mysql-local.env` file for your database credentials.
5. Add the MCP server to `claude_desktop_config.json`, pointed at the wrapper script.

Claude will tell you the exact path to `mysql-local.env` and ask you to open it yourself in a text editor and type in the five values Mike gives you — never paste them into the chat. Because the wrapper script loads credentials from that file at launch time, your database password never has to appear in `claude_desktop_config.json`, this repository's tracked files, or anywhere Claude can read.

**If you choose Path A, stop here and follow Claude's instructions. Do not also complete Path B.**

### Path B — Manual setup

Use the steps below if you don't have a Claude session with terminal access to this computer, or prefer to do the setup yourself.

#### Claude manual step 1: Install Node.js

Follow [Manual step 1: Install Node.js](#manual-step-1-install-nodejs) from the ChatGPT/Codex section above to install Node.js and find the full path to `npx`.

#### Claude manual step 2: Get read-only database credentials

Get the five values listed in [Manual step 2: Get read-only database credentials](#manual-step-2-get-read-only-database-credentials) from Mike through the company password manager or another approved secure channel.

#### Claude manual step 3: Add the MCP server to Claude Desktop

1. In Claude Desktop, open **Settings** > **Developer**.
2. Select **Edit Config**. This opens `claude_desktop_config.json`.
3. Add the configuration below. Replace the `command` value with the full path to `npx`, and replace all five database placeholders.
4. If the file already contains an `mcpServers` object, add only the `mysql-local` entry inside it. Do not erase other configured servers.

```json
{
  "mcpServers": {
    "mysql-local": {
      "command": "/replace/with/the/full/path/to/npx",
      "args": ["-y", "@benborla29/mcp-server-mysql@2.0.9"],
      "env": {
        "MYSQL_HOST": "<read-only database host>",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "<read-only username>",
        "MYSQL_PASS": "<read-only password>",
        "MYSQL_DB": "<database name>"
      }
    }
  }
}
```

Do not add `ALLOW_INSERT_OPERATION`, `ALLOW_UPDATE_OPERATION`, or `ALLOW_DELETE_OPERATION`.

This local Claude configuration contains the database password. Never copy it into this repository, a Claude conversation, Slack, email, or a screenshot. Do not share or commit the file. (If you'd rather the password never touch this file at all, use Path A instead — it keeps credentials only in the git-ignored `mysql-local.env`.)

5. Save the configuration file.
6. Fully quit Claude Desktop — not just its window — and reopen it.
7. Return to **Settings** > **Developer** and confirm that `mysql-local` appears as a running local MCP server.

#### Claude manual step 4: Verify the connection

Start a new Claude conversation and paste:

```text
Use mysql-local to run a read-only connection check. Return the server hostname,
port, selected database, database version, and whether the tables accounts,
prospects, and assessment_scores exist. Do not show credentials.
```

If Claude asks permission to use `mysql-local`, review the request and allow it. A healthy full-data connection should find `accounts`, `prospects`, and `assessment_scores`.

### Ask a data question with Claude

For regular Claude Desktop conversations, perform this one-time setup:

1. Create a Claude Project named `Zorakle Analytics`.
2. Add [AGENTS.md](./AGENTS.md) to the project's knowledge.
3. Start all Zorakle database conversations inside that project.

Claude will use those instructions in every conversation in the project. You can ask a business question directly without pasting the starter prompt again.

If you use Claude Code with this repository, [CLAUDE.md](./CLAUDE.md) imports `AGENTS.md` automatically at the start of each session.

## Troubleshooting

### `mysql-local` does not appear in ChatGPT/Codex

Restart ChatGPT, open a Codex task, and type `/mcp`. Return to **Settings** > **MCP servers** and confirm the server is enabled.

### `mysql-local` does not appear in Claude Desktop

Fully quit and reopen Claude Desktop. Open **Settings** > **Developer**, check the local MCP server status, and confirm that the JSON file contains valid syntax and the complete path to `npx`.

### `node`, `npx`, or the server cannot be found

Reinstall Node.js LTS, restart the desktop app you are using, and repeat manual step 1. Use the complete path printed by `which npx` or `where.exe npx` as the MCP command.

### The server times out on its first start

The first launch downloads the pinned package and can take longer. Confirm the computer has internet access, restart ChatGPT or Claude Desktop, and try once more. If it still times out on the first start, wait a minute for the background download to finish and restart the app again.

### MySQL says “Access denied”

Re-enter all five database values exactly. If they are correct, ask Mike whether your network address must be allowed or the read-only password must be reset.

### A result looks too high

Ask ChatGPT or Claude to compare `COUNT(*)` with `COUNT(DISTINCT prospects.id)` and show the count before and after each join. Tables such as `answers` and `eclipse_profiles` can contain multiple rows per prospect.

## What is in this repository?

- [AGENTS.md](./AGENTS.md): automatically loaded Zorakle data, safety, validation, and reporting instructions for Codex
- [CLAUDE.md](./CLAUDE.md): loads the same instructions automatically in Claude Code
- [INSTALL_WITH_CODEX.md](./INSTALL_WITH_CODEX.md): instructions that let Codex check and install Node.js and the MCP server for the user
- [INSTALL_WITH_CLAUDE.md](./INSTALL_WITH_CLAUDE.md): instructions that let a Claude session with local terminal access do the same for Claude Desktop, without ever seeing your database password
- `bin/mysql-local-mcp.sh` / `bin/mysql-local-mcp.cmd`: wrapper scripts (created by Path A) that load `mysql-local.env` and launch the pinned MCP server, so Claude Desktop's own config never has to hold the password
- `mysql-local.env.example`: template for the five database values; copy it to the git-ignored `mysql-local.env` and fill in your own credentials there
- [LICENSE](./LICENSE): internal-use terms — this repository is proprietary to Zorakle and not for external distribution

## References

- [Official ChatGPT desktop app guide](https://learn.chatgpt.com/docs/app)
- [Official ChatGPT and Codex MCP guide](https://learn.chatgpt.com/docs/extend/mcp)
- [Official Codex `AGENTS.md` guide](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Official Claude Desktop installation guide](https://support.claude.com/en/articles/10065433-install-claude-desktop)
- [Official Claude local MCP server guide](https://support.claude.com/en/articles/10949351-getting-started-with-local-mcp-servers-on-claude-desktop)
- [Official Claude Projects guide](https://support.claude.com/en/articles/9517075-what-are-projects)
- [Official Claude `CLAUDE.md` guide](https://code.claude.com/docs/en/memory)
- [`@benborla29/mcp-server-mysql` source repository](https://github.com/benborla/mcp-server-mysql)
