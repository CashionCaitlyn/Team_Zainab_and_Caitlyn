#!/bin/bash

TARGET_DIR=$1 # Defined the target directory from the first argument 
OUTPUT_DIR="forensic_report_$(date +%Y%m%d_%H%M%S)" # Created a timestamped directory for forensic arifacts to prevent overwriting 
API_KEY="PUT_KEY_HERE" # API key for analysis 

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then # Ensured the user provided a directory and verify that it exists 
    echo "Usage: ./triage_pro.sh <target_directory>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR/carved_files" # Intialized output structure for data storage 
TIMELINE="$OUTPUT_DIR/timeline.csv"

echo "[+] Starting Triage on: $TARGET_DIR"

echo "[+] Extracting metadata and building timeline..."

echo "Filename|Size(Bytes)|Permissions|Owner|Last_Modified" > "$TIMELINE" # Created a CSV header for data analysis 

find "$TARGET_DIR" -type f -exec stat --printf="%n|%s|%A|%U|%y\n" {} + >> "$TIMELINE" #Scans files repeatedly and extract MAC times and permissions 

sort -t'|' -k5 "$TIMELINE" -o "$TIMELINE" #Will sort the timeline from oldest to newest

echo "[+] Timeline saved to: $TIMELINE"

echo "[+] Running 'foremost' to carve deleted/hidden files..."

if command -v foremost &>/dev/null; then #Run quiet mode to extract files based on headers and footers 
    foremost -i "$TARGET_DIR" -o "$OUTPUT_DIR/carved_files" -q 2>/dev/null
    echo "[+] Carving complete. See: $OUTPUT_DIR/carved_files"
else
    echo "[!] foremost not found. Install with: sudo apt install foremost"
    echo "[!] Skipping file carving."
fi

echo "[+] Sending data to AI for expert interpretation..."

DATA_SNIPPET=$(tail -n 20 "$TIMELINE")

ESCAPED_DATA=$(echo "$DATA_SNIPPET" | python3 -c "
import sys, json
print(json.dumps(sys.stdin.read()))
")

AI_SUMMARY=$(curl -s https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d "{
    \"model\": \"claude-haiku-4-5-20251001\",
    \"max_tokens\": 1024,
    \"system\": \"You are a Senior Digital Forensics Investigator. Explain the following file activity timeline in simple, plain English for a non-technical audience such as a jury. Highlight suspicious patterns like late-night modifications, unusual file sizes, unexpected file types, or hidden files.\",
    \"messages\": [
      {\"role\": \"user\", \"content\": \"Here is the timeline data:\\n$DATA_SNIPPET\"}
    ]
  }" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data['content'][0]['text'])
except Exception as e:
    print('[AI Error] Could not parse response: ' + str(e))
")

#AI REPORT
FINAL_REPORT="$OUTPUT_DIR/SUMMARY_REPORT.txt"

{
    echo "FILE EXAMINER REPORT"
    echo "------------------------------"
    echo "Target Directory: $TARGET_DIR"
    echo "Scan Date: $(date)"
    echo ""
    echo "[AI SUMMARY]"
    echo ""
    echo "$AI_SUMMARY"
    echo ""
    echo "[RESOURCES FOUND]"
    echo ""
    echo "Timeline:       $TIMELINE"
    echo "Carved Files Folder: $OUTPUT_DIR/carved_files"
} > "$FINAL_REPORT"

echo "----------------------------------------------------"
echo "[!] ANALYSIS COMPLETE"
echo "[!] Complete summary can be viewed here: $FINAL_REPORT"
