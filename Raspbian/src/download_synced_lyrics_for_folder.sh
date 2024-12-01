#!/usr/bin/env bash

# Uses the syncedlyrics Python library: https://github.com/moehmeni/syncedlyrics

# Assign the first argument to the variable 'dir'.
dir="$1"

# Assign the current directory (from dir) to 'album'
album=$(basename "$dir")

# Get the parent directory of 'album' and assign it to 'artist'
artist=$(basename "$(dirname "$dir")")

# Print the directories to the console.
echo "The directory provided is: $dir"
echo "The album directory is: $album"
echo "The artist directory is: $artist"

# Create a list of all .flac and .mp3 files in the 'dir' directory.
music_files=$(find "$dir" -type f \( -name "*.flac" -o -name "*.mp3" \))

# Initialize an empty array for track names without extensions.
track_names=()

# Loop through each music file and process the name without the extension.
while IFS= read -r file; do
  filename=$(basename "$file")
  track_name="${filename%.*}"
  track_names+=("$track_name")
  # echo "Music file: $filename"
done <<< "$music_files"

# Optionally, print all track names without extensions.
echo "Track names without extensions:"
for name in "${track_names[@]}"; do
  echo "$name"
done

for track_name in "${track_names[@]}"; do
  output_file="${dir}/${track_name}.lrc"

  # Check if the output file already exists.
  if [ ! -f "$output_file" ]; then
    ./bin/syncedlyrics "${artist} ${album} ${track_name}" --output "$output_file"
    echo "Processed: $track_name"
    sleep 10
  else
    echo "Skipped: $track_name (already exists)"
  fi
done
