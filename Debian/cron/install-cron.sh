#!/usr/bin/env bash

# Install (or update) the managed block of cron jobs for this server.
#
# Usage: ./install-cron.sh [--dry-run] [path/to/jobs-file]
#
# Safe to re-run: only the block between the two markers below is replaced,
# and any other crontab entries are left alone.

# Exit on any error, on use of an unset variable, and on failures in pipelines.
set -euo pipefail

# Markers that wrap the block of jobs this script owns.
BEGIN_MARKER="# >>> managed by setting-up-my-computer (Debian/cron) >>>"
END_MARKER="# <<< managed by setting-up-my-computer (Debian/cron) <<<"

# Directory that holds this script, so it works from any working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Where the job logs and crontab backups live (must match the crontab file).
LOG_DIR="${HOME}/.local/state/cron"

# Defaults, which the command-line arguments below can override.
DRY_RUN=false
JOBS_FILE="${SCRIPT_DIR}/crontab"

# Print usage and exit.
usage() {
  # Print the one-line usage summary.
  echo "Usage: $0 [--dry-run] [path/to/jobs-file]"
  exit "${1:-0}"
}

# Parse the command-line arguments.
for arg in "$@"; do
  case "$arg" in
    # Show what would be installed without touching the crontab.
    --dry-run) DRY_RUN=true ;;
    # Show usage.
    -h|--help) usage 0 ;;
    # Anything starting with a dash that we do not know is an error.
    -*) echo "Unknown option: $arg" >&2; usage 1 ;;
    # Anything else is the path to a jobs file.
    *) JOBS_FILE="$arg" ;;
  esac
done

# The crontab command only exists if the cron package is installed.
if ! command -v crontab > /dev/null 2>&1; then
  echo "crontab not found. Install it with: sudo apt install cron" >&2
  exit 1
fi

# The jobs file must exist and be readable.
if [[ ! -r "$JOBS_FILE" ]]; then
  echo "Jobs file not found or unreadable: $JOBS_FILE" >&2
  exit 1
fi

# Refuse to install while any job still has the REPLACE_SCHEDULE placeholder.
# Only uncommented lines count, because the placeholder is also mentioned in comments.
if grep -Eq '^[[:space:]]*REPLACE_SCHEDULE' "$JOBS_FILE"; then
  echo "Unfilled schedules found in $JOBS_FILE:" >&2
  grep -En '^[[:space:]]*REPLACE_SCHEDULE' "$JOBS_FILE" | cut -c1-110 >&2
  echo "Replace each REPLACE_SCHEDULE with five cron fields and re-run." >&2
  exit 1
fi

# Warn (but do not fail) about scripts referenced via $HOME that do not exist yet.
# Tokens containing quotes are skipped because they cannot be split reliably.
while IFS= read -r line; do
  # Skip comments, blank lines, and VAR=value assignments.
  [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
  [[ "$line" =~ ^[A-Za-z_]+= ]] && continue
  # Look at each whitespace-separated word on the line.
  for word in $line; do
    # Only check words that start with $HOME/ and contain no quote characters.
    # Log files are skipped because the jobs create them on first run.
    if [[ "$word" == '$HOME/'* && "$word" != *.log && "$word" != *\"* && "$word" != *\'* ]]; then
      # Swap the literal $HOME for the real home directory.
      path="${HOME}/${word#\$HOME/}"
      # Tell the user if the file is missing.
      [[ -e "$path" ]] || echo "Warning: referenced path does not exist yet: $path" >&2
    fi
  done
done < "$JOBS_FILE"

# Make sure the log directory exists before any job tries to write to it.
mkdir -p "$LOG_DIR"

# Capture the current crontab; "no crontab" is not an error here.
CURRENT="$(crontab -l 2>/dev/null || true)"

# Remove any previous managed block, keeping everything outside the markers.
STRIPPED="$(printf '%s\n' "$CURRENT" | awk -v b="$BEGIN_MARKER" -v e="$END_MARKER" '
  # Start skipping at the begin marker.
  $0 == b { skip = 1; next }
  # Stop skipping after the end marker.
  $0 == e { skip = 0; next }
  # Print every line that is not inside the block.
  !skip { print }
')"

# Build the new crontab in a temp file that is cleaned up on exit.
NEW_FILE="$(mktemp)"
trap 'rm -f "$NEW_FILE"' EXIT
{
  # Keep existing unmanaged entries first, followed by a blank separator line.
  if [[ -n "${STRIPPED//[[:space:]]/}" ]]; then
    printf '%s\n\n' "$STRIPPED"
  fi
  # Then the managed block: marker, jobs, marker.
  printf '%s\n' "$BEGIN_MARKER"
  cat "$JOBS_FILE"
  printf '%s\n' "$END_MARKER"
} > "$NEW_FILE"

# In dry-run mode, show the result and stop without changing anything.
if [[ "$DRY_RUN" == true ]]; then
  echo "--- Dry run: this is what would be installed ---"
  cat "$NEW_FILE"
  exit 0
fi

# Back up the existing crontab (if there is one) before replacing it.
if [[ -n "${CURRENT//[[:space:]]/}" ]]; then
  BACKUP="${LOG_DIR}/crontab.backup.$(date +%Y%m%d-%H%M%S)"
  printf '%s\n' "$CURRENT" > "$BACKUP"
  echo "Backed up the existing crontab to $BACKUP"
fi

# Install the new crontab.
crontab "$NEW_FILE"
echo "Installed. Current crontab:"
crontab -l

# Cron only runs if its service is up; warn if it is not.
if command -v systemctl > /dev/null 2>&1 && ! systemctl is-active --quiet cron; then
  echo "Warning: the cron service is not running. Try: sudo systemctl enable --now cron" >&2
fi
