#!/bin/bash

TARGET_DIR=$1 #First argument to be passed to the script, which is the target directory
OUTPUT_FILE="forensic_timeline.txt" #Define filenames 
CARVE_DIR="./carved_files"

#Check if user provided a directory path
if [[ -z "$TARGET_DIR" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

echo "Starting Forensic Analysis on: $TARGET_DIR"

#
generate_timeline() {
    echo "[+] Extracting metadata and generating timeline..."
    # Using 'find' to grab files and 'stat' to format the output
    # Format: Access Time | Modify Time | Change Time | Permissions | Size | Name
    find "$TARGET_DIR" -type f -exec stat --printf "%x | %y | %z | %A | %s | %n\n" {} + | sort > "$OUTPUT_FILE"
    echo "[*] Timeline saved to $OUTPUT_FILE"
}

run_carving() {
    echo "[+] Starting file carving with Scalpel..."
    mkdir -p "$CARVE_DIR"
    # Note: Scalpel requires a config file. Ensure it's set up in /etc/scalpel/scalpel.conf
    scalpel -o "$CARVE_DIR" "$TARGET_DIR"
}



}


echo "Analysis Complete."
