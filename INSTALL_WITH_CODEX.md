# Install Node.js With Codex

This file is written for Codex. The person setting up this project should not need to run terminal commands themselves.

## Instructions for Codex

Help the user prepare this computer to run the `mysql-local` MCP server. Perform the technical checks and safe installation steps yourself instead of asking the user to copy terminal commands.

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
   - If no suitable package manager is available, open or direct the user to the official Node.js LTS installer at https://nodejs.org/en/download and give only the minimum clicks needed.
7. Verify the completed installation by running `node --version`, `npx --version`, and the operating system's command for locating `npx` (`which npx` on macOS/Linux or `where.exe npx` on Windows).
8. Verify that `@benborla29/mcp-server-mysql@2.0.9` is available from npm without starting it or requesting database credentials.
9. Give the user the full detected path to `npx` and guide them through **Settings > MCP servers > Add server** in the ChatGPT desktop app using the values in `README.md`.
10. Do not ask the user to paste a database password into chat or place it in a repository file. Tell them to enter the five database values directly into the MCP server environment-variable fields. They should obtain those values from Mike through the approved password manager.
11. After the user saves and restarts the MCP server, help them run the read-only connection check from `README.md`.

Stop and clearly explain the next manual action if an installer, administrator password, company device policy, missing package manager, or MCP Settings screen prevents you from continuing safely.

