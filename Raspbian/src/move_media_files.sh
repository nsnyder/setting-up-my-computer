#!/bin/bash
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <folder_path> <target_base_path> [dry_run]"
    exit 1
fi

folder_path=$1
target_base_path=$2
dry_run=${3:-false}

# Regex to extract date and time (example: 20220101_123456)
regex=".*([0-9]{8})_([0-9]{6}).*"

if [ "$dry_run" == "true" ]; then
    echo "Dry run mode enabled. No files will be moved, modified, or deleted."
fi

for file in "$folder_path"/*; do
    if [[ $(basename "$file") =~ $regex ]]; then
        date_part=${BASH_REMATCH[1]}
        time_part=${BASH_REMATCH[2]}

        # Convert to touch format (example: 20220101_123456 -> 202201011234.56)
        touch_format="${date_part:0:8}${time_part:0:4}.${time_part:4:2}"
        # Create target directory based on date
        target_dir="$target_base_path/${date_part:0:4}/${date_part:4:2}/${date_part:6:2}"
        [ "$dry_run" == "false" ] && mkdir -p -m 777 "$target_dir"

        # Move the file to the target directory
        if [ "$dry_run" == "false" ]; then
            if [ ! -e "$target_dir/$(basename "$file")" ]; then
                mv "$file" "$target_dir/"
                echo "Moved $file to $target_dir/"
            else
                echo "SKIPPING: File $file already exists in $target_dir/"
            fi
        fi
    else
        echo "No date/time found in $file"
    fi
done

# Add a crontab entry to run the script hourly
# (crontab -l 2>/dev/null; echo "0 * * * * /home/nathan/projects/setting-up-my-computer/Raspbian/src/move_media_files.sh /media/mycloud/Pictures/Nathan\'s\ Phone/Unorganized/ /media/mycloud/Pictures/Nathan\'s\ Phone") | crontab -
