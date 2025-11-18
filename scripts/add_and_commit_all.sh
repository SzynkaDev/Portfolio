#!/usr/bin/env bash
set -euo pipefail

# add_and_commit_all.sh
# Usage: ./add_and_commit_all.sh [commit-message] [push]
# Examples:
#   ./add_and_commit_all.sh "Add all files"        # commit only
#   ./add_and_commit_all.sh "Add all files" push   # commit and push

cd "$(git rev-parse --show-toplevel)"

msg="${1:-Add all folders}"
push_flag="${2:-}"

git add -A

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "$msg"

if [ "$push_flag" = "push" ] || [ "$push_flag" = "--push" ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "Pushing to origin/$branch..."
  git push origin "$branch"
fi

echo "Done."
