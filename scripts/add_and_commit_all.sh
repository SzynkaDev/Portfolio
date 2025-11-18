#!/usr/bin/env bash
set -euo pipefail

# add_and_commit_all.sh
# Ensures empty directories are tracked (adds .gitkeep), stages all changes,
# commits with the provided message (default shown below), and pushes to
# the current branch on `origin` by default. Use `--no-push` to skip pushing.
#
# Usage:
#   ./scripts/add_and_commit_all.sh [commit-message] [--no-push]
# Examples:
#   ./scripts/add_and_commit_all.sh "Ensure all folders visible"
#   ./scripts/add_and_commit_all.sh "Update" --no-push

cd "$(git rev-parse --show-toplevel)"

msg="${1:-Add all files and ensure folders tracked}"
no_push=false
if [ "${2:-}" = "--no-push" ] || [ "${1:-}" = "--no-push" ]; then
  no_push=true
fi

# Create .gitkeep files in empty directories so git can track folder structure.
# Skip the .git directory and any existing .gitkeep files.
echo "Scanning for empty directories (adding .gitkeep where needed)..."
while IFS= read -r -d '' dir; do
  # Ignore .git and mount points
  case "$dir" in
    */.git|/.git) continue ;;
  esac
  # Check if directory contains any non-.gitkeep files
  if [ -z "$(find "$dir" -maxdepth 1 -mindepth 1 ! -name '.gitkeep' -print -quit 2>/dev/null)" ]; then
    if [ ! -e "$dir/.gitkeep" ]; then
      echo "Adding .gitkeep -> $dir/.gitkeep"
      mkdir -p "$dir" && : > "$dir/.gitkeep"
    fi
  fi
done < <(find . -type d -not -path './.git*' -print0)

git add -A

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  exit 0
fi

echo "Committing with message: $msg"
git commit -m "$msg"

if [ "$no_push" = false ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "Pushing to origin/$branch..."
  git push origin "$branch"
else
  echo "Skipping push (requested)."
fi

echo "Done."
