#!/bin/bash

# Verify the number of arguments: 2 required, 1 optional (dry_run).
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <folder_path> <target_base_path> [dry_run]"
    exit 1
fi

# Folder containing the unsorted files.
folder_path=$1
# Base folder under which YYYY/MM/DD directories are created.
target_base_path=$2
# Dry run flag; defaults to "false" when the third argument is omitted.
dry_run=${3:-false}

# Tracks whether exiftool is available; assume yes until checked below.
has_exiftool=true

# Warn (but do not abort) if exiftool is missing; filenames will be used instead.
if ! command -v exiftool >/dev/null 2>&1; then
    has_exiftool=false
    echo "WARNING: exiftool not found. Falling back to filename dates only (may group by UTC)."
    echo "         Install with: sudo apt install libimage-exiftool-perl"
fi

# Fallback regex to extract date and time from a filename (example: 20220101_123456).
regex=".*([0-9]{8})_([0-9]{6}).*"

# Announce dry run mode so the operator knows nothing will change.
if [ "$dry_run" == "true" ]; then
    echo "Dry run mode enabled. No files will be moved, modified, or deleted."
fi

# Echo "YYYYMMDD_HHMMSS" for a file using metadata first, then filename.
# Prints nothing (and returns 1) if neither source yields a usable date.
get_date_time() {
    # Path of the file being examined.
    local file=$1
    # Holds the date/time string once found.
    local result=""

    # Only attempt metadata extraction when exiftool is installed.
    if [ "$has_exiftool" == "true" ]; then
        # Ask exiftool for capture-time tags, in priority order:
        #   -s3  : print only the raw values (no tag names)
        #   -m   : ignore minor errors/warnings in malformed metadata
        #   -d   : format dates as YYYYMMDD_HHMMSS
        # head -n1 keeps the first tag that actually had a value.
        result=$(exiftool -s3 -m -d '%Y%m%d_%H%M%S' \
            -DateTimeOriginal -CreateDate -MediaCreateDate \
            "$file" 2>/dev/null | head -n1)

        # Accept the metadata value only if it looks like a real date.
        # This rejects empty output and zeroed-out dates such as 0000:00:00.
        if [[ "$result" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{6})$ ]] \
            && [ "${BASH_REMATCH[1]}" -ge 1990 ]; then
            echo "$result"
            return 0
        fi
    fi

    # Metadata unavailable or unusable, so fall back to parsing the filename.
    if [[ $(basename "$file") =~ $regex ]]; then
        echo "${BASH_REMATCH[1]}_${BASH_REMATCH[2]}"
        return 0
    fi

    # Neither source worked.
    return 1
}

# Loop over every entry in the source folder.
for file in "$folder_path"/*; do
    # Skip directories and the literal "*" produced when the folder is empty.
    [ -f "$file" ] || continue

    # Determine the date/time; report and skip the file if none can be found.
    if ! date_time=$(get_date_time "$file"); then
        echo "No date/time found in metadata or filename for $file"
        continue
    fi

    # Split "YYYYMMDD_HHMMSS" into its date portion.
    date_part=${date_time%_*}

    # Build the target directory path from the date (YYYY/MM/DD).
    target_dir="$target_base_path/${date_part:0:4}/${date_part:4:2}/${date_part:6:2}"
    # Final destination path for this file.
    target_file="$target_dir/$(basename "$file")"

    # In dry run mode, only report what would happen.
    if [ "$dry_run" == "true" ]; then
        echo "[DRY RUN] Would move $file to $target_dir/"
        continue
    fi

    # Create the target directory (world-writable, matching the original behavior).
    mkdir -p -m 777 "$target_dir"

    # Move the file unless one with the same name already exists at the destination.
    if [ ! -e "$target_file" ]; then
        mv "$file" "$target_dir/"
        echo "Moved $file to $target_dir/"
    else
        echo "SKIPPING: File $file already exists in $target_dir/"
    fi
done

# Add a crontab entry to run the script hourly
# (crontab -l 2>/dev/null; echo "0 * * * * /home/nathan/projects/setting-up-my-computer/Raspbian/src/move_media_files.sh /media/mycloud/Pictures/Nathan\'s\ Phone/Unorganized/ /media/mycloud/Pictures/Nathan\'s\ Phone") | crontab -
