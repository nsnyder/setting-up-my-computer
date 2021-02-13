#!/usr/bin/env bash

# Adapted from: https://superuser.com/questions/707261/shell-script-bash-moving-file-iterate-based-on-month

BASE_DIR=$1

if [[ ! -n $BASE_DIR ]] ; then
    echo "You must provide a base directory argument."
    exit 1
fi

## Find those files that are older than a month
find "$BASE_DIR" -maxdepth 1 -type f -name "20*" |
while IFS= read -r file; do
    date="$(date -d "$(cut -c1-9 $file)")"

    ## Get the file's modification year
    year="$(date -d "$date" +%Y)"
    ## Get the file's modification month
    month="$(date -d "$date" +%b)"

    ## Create the directories if they don't exist. The -p flag
    ## makes 'mkdir' create the parent directories as needed so
    ## you don't need to create $year explicitly.
    [[ ! -d "$BASE_DIR/$year/$month" ]] && mkdir -p "$BASE_DIR/$year/$month"; 

    ## Move the file
    mv "$file" "$BASE_DIR/$year/$month"
done
