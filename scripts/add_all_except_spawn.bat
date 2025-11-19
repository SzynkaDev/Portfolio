@echo off
REM Adds all files to git except the specified file, commits, and pushes.

REM Relative path (from repo root) to exclude. Update if file moves.
set "EXCLUDE=scripts\codes\spawn.sk"

REM Check we're in a git repo root
if not exist ".git" (
  echo .git not found in the current directory.
  echo Run this script from the repository root (where .git is located).
  exit /b 1
)

echo Adding all files to staging...
git add .

echo Removing excluded file from staging: %EXCLUDE%
git reset -- "%EXCLUDE%"

echo Showing staged changes:
git status --porcelain

REM Build commit message from args or use default
if "%~1"=="" (
  set "MSG=Add all files (except %EXCLUDE%)"
) else (
  set "MSG=%*"
)

echo Committing with message: %MSG%
git commit -m "%MSG%"
if %ERRORLEVEL% NEQ 0 (
  echo No commit created (no staged changes) or commit failed.
  echo If you only wanted to stage changes, the excluded file is unstaged now.
  exit /b 0
)

echo Commit created successfully. Pushing to remote...
git push

endlocal
