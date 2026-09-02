@echo off
REM Launches the mysql-local MCP server for Claude Desktop on Windows.
REM Credentials live in mysql-local.env (untracked) next to this repo, never
REM in claude_desktop_config.json and never in chat.
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "ENV_FILE=%SCRIPT_DIR%..\mysql-local.env"

if not exist "%ENV_FILE%" (
  echo Missing %ENV_FILE%.
  echo Copy mysql-local.env.example to mysql-local.env and fill in the five database values, then try again.
  exit /b 1
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
  if not "%%A"=="" set "%%A=%%B"
)

if "%MYSQL_HOST%"=="" (echo mysql-local.env is missing MYSQL_HOST & exit /b 1)
if "%MYSQL_PORT%"=="" (echo mysql-local.env is missing MYSQL_PORT & exit /b 1)
if "%MYSQL_USER%"=="" (echo mysql-local.env is missing MYSQL_USER & exit /b 1)
if "%MYSQL_PASS%"=="" (echo mysql-local.env is missing MYSQL_PASS & exit /b 1)
if "%MYSQL_DB%"=="" (echo mysql-local.env is missing MYSQL_DB & exit /b 1)

npx -y @benborla29/mcp-server-mysql@2.0.9
