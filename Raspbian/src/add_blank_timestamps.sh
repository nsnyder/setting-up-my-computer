#!/bin/bash

process_file() {
    local file="$1"

    # Create a temporary file
    tmpfile=$(mktemp)
    chmod 777 "$tmpfile"

    # Extract the final file name without the directory structure
    filename=$(basename "$file")

    # Prompt user for songwriter and producer for each file.
    read -p "Enter the songwriter for '$filename' (leave blank if none): " songwriter
    read -p "Enter the producer for '$filename' (leave blank if none): " producer

    # Prompt user for songwriter and producer for each file.
    # read -p "Enter the songwriter for '$file' (leave blank if none): " songwriter
    # read -p "Enter the producer for '$file' (leave blank if none): " producer

    # Initialize a flag to keep track of the previous line.
    previous_line=""
    produced_by_line=""
    written_by_line=""
    written_by_exists=false
    produced_by_exists=false
    is_first_line=true

    # Initialize the written and produced by lines.
    if [[ -n "$songwriter" ]]; then
        written_by_line="[59:00.00] Written by: $songwriter"
    fi
    if [[ -n "$producer" ]]; then
        produced_by_line="[59:00.00] Produced by: $producer"
    fi

    # Read the file line by line.
    while IFS= read -r line; do
        # Skip empty lines.
        [[ -z "$line" ]] && continue

        # Make a note of current written by and produced by lines.
        # Skip them. We'll add at the end.
        if [[ "$line" == "[59:00.00] Written by:"* ]]; then
            written_by_exists=true

            if [[ -z "$songwriter" ]]; then
                written_by_line="$line"
            fi

            continue
        elif [[ "$line" == "[59:00.00] Produced by:"* ]]; then
            produced_by_exists=true

            if [[ -z "$producer" ]]; then
                produced_by_line="$line"
            fi

            continue
        fi

        # Check if the current line contains empty brackets `[]`.
        if [[ "$previous_line" == "[]" ]]; then
            # Extract the timestamp from the current line
            timestamp=$(echo "$line" | grep -oE '^\[[0-9]{2}:[0-9]{2}\.[0-9]{2,}\]')
            # Replace the empty brackets in the previous line with the timestamp.
            previous_line="$timestamp "
        fi

        # Write the previous line to the temporary file.
        if [[ "$is_first_line" == false ]]; then
            echo "$previous_line" >> "$tmpfile"
        else
            is_first_line=false
        fi

        # Set the current line as the previous line for the next iteration.
        previous_line="$line"
    done < "$file"

    # Write the last line to the temporary file.
    echo "$previous_line" >> "$tmpfile"

    # Add a blank line if we don't have credits yet, and input was provided.
    if [[ "$written_by_exists" == false && "$produced_by_exists" == false && (-n "$songwriter" || -n "$producer") ]]; then
        echo "[59:00.00] " >> "$tmpfile"
    fi

    # Add new credits if they didn't exist and input was provided.
    if [[ -n "$written_by_line" ]]; then
        echo "$written_by_line" >> "$tmpfile"
    fi
    if [[ -n "$produced_by_line" ]]; then
        echo "$produced_by_line" >> "$tmpfile"
    fi

    # Ensure an empty line at the end of the file
    # echo "" >> "$tmpfile"

    # Replace the original file with the modified content.
    cp "$tmpfile" "$file"
}

# Main script logic
INPUT="$1"

if [[ -d "$INPUT" ]]; then
    # If the input is a directory, process all .lrc files within it
    for file in "$INPUT"/*.lrc; do
        process_file "$file"
    done
elif [[ -f "$INPUT" && "$INPUT" == *.lrc ]]; then
    # If the input is a single .lrc file, process that file
    process_file "$INPUT"
else
    echo "Error: Please provide a valid .lrc file or a directory containing .lrc files."
    exit 1
fi
