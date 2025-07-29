#!/bin/bash

LOGFILE=~/InjectJirachi.log
BACKUP_DIR=~/backupSaves
MODIFIED_SAV=~/modified.sav

FILL_PARTY_FLAG=""
if [[ "$1" == "--fill-party" ]]; then
    FILL_PARTY_FLAG="--fill-party"
fi

# clear log file
: > "$LOGFILE"

# create backup directory if it doesnt exist already
mkdir -p "$BACKUP_DIR"

# find the next available backup filename
i=0
while [[ -e "$BACKUP_DIR/backup$i.sav" ]]; do
    ((i++))
done
BACKUP_FILE="$BACKUP_DIR/backup$i.sav"

# run flashgbx and exit if it takes more than 30s
run_flashgbx() {
    local cmd=("$@")
    echo "Running: ${cmd[*]}" | tee -a "$LOGFILE"

    TMP_OUTPUT=$(mktemp)
    
    timeout 30s stdbuf -oL -eL "${cmd[@]}" 2>&1 | tee "$TMP_OUTPUT" | tee -a "$LOGFILE"
    RETVAL=${PIPESTATUS[0]}

    # save output for debug msg matching
    OUTPUT=$(<"$TMP_OUTPUT")
    rm -f "$TMP_OUTPUT"
}

# ------------------- backup save -------------------
run_flashgbx flashgbx --cli --mode agb --action backup-save "$BACKUP_FILE"

if echo "$OUTPUT" | grep -q "Invalid data was detected which usually means that the cartridge couldn’t be read correctly"; then
    echo "DEBUG: flashgbx reported invalid cartridge data. Exiting with code 1." | tee -a "$LOGFILE"
    exit 1
elif echo "$OUTPUT" | grep -q "Error: No response while trying to communicate with the device."; then
    echo "DEBUG: flashgbx communication failure. Killing process and exiting with code 2." | tee -a "$LOGFILE"
    pkill -f "flashgbx"
    exit 2
elif echo "$OUTPUT" | grep -q "The save data backup is complete!" && [[ $RETVAL -eq 0 ]]; then
    echo "Backup succeeded." | tee -a "$LOGFILE"
else
    echo "DEBUG: Unknown backup error. Output did not match expected patterns. Exiting with code 3." | tee -a "$LOGFILE"
    exit 3
fi

# ------------------- InjectJirachi -------------------
echo "Running InjectJirachi..." | tee -a "$LOGFILE"

TMP_INJECT_OUTPUT=$(mktemp)
~/InjectJirachi/InjectJirachi "$BACKUP_FILE" "$MODIFIED_SAV" $FILL_PARTY_FLAG 2>&1 | tee "$TMP_INJECT_OUTPUT" | tee -a "$LOGFILE"
INJECT_EXIT_CODE=${PIPESTATUS[0]}
INJECT_OUTPUT=$(<"$TMP_INJECT_OUTPUT")
rm -f "$TMP_INJECT_OUTPUT"

# extract first partySize number from InjectJirachi output
INITIAL_PARTY_SIZE=$(echo "$INJECT_OUTPUT" | grep -m1 "partySize:" | grep -oE '[0-9]+')
MAX_PARTY_SIZE=6

case $INJECT_EXIT_CODE in
    0)
        echo "DEBUG: InjectJirachi completed successfully (InjectJirachi exit 0)." | tee -a "$LOGFILE"
        ;;
    1)
        if echo "$INJECT_OUTPUT" | grep -q "No open party slot found."; then
            echo "DEBUG: Full party message received from InjectJirachi." | tee -a "$LOGFILE"
        fi

        if [[ "$FILL_PARTY_FLAG" == "--fill-party" ]]; then
            if [[ "$INITIAL_PARTY_SIZE" -ge "$MAX_PARTY_SIZE" ]]; then
                echo "DEBUG: Party was already full before injection; treating as failure. (exit 7)" | tee -a "$LOGFILE"
                exit 7
            else
                echo "DEBUG: --fill-party was set and party got filled, continuing main program." | tee -a "$LOGFILE"
            fi
        else
            echo "DEBUG: Party full and --fill-party not set (exit 7)." | tee -a "$LOGFILE"
            exit 7
        fi
        ;;
    2)
        echo "DEBUG: InjectJirachi failed — invalid save or generation error (InjectJirachi exit 2) (exit 6)." | tee -a "$LOGFILE"
        exit 6
        ;;
    *)
        echo "DEBUG: InjectJirachi failed with unknown exit code $INJECT_EXIT_CODE. (exit 4)" | tee -a "$LOGFILE"
        exit 4
        ;;
esac



# check if newly-created modified save file exists
if [[ ! -f "$MODIFIED_SAV" ]]; then
    echo "DEBUG: Modified save file not found: $MODIFIED_SAV. Exiting with code 5." | tee -a "$LOGFILE"
    exit 5
fi

# ------------------- restore save -------------------
run_flashgbx flashgbx --cli --mode agb --action restore-save "$MODIFIED_SAV" --overwrite

if echo "$OUTPUT" | grep -q "Invalid data was detected which usually means that the cartridge couldn’t be read correctly"; then
    echo "DEBUG: flashgbx restore reported invalid cartridge data. Exiting with code 1." | tee -a "$LOGFILE"
    exit 1
elif echo "$OUTPUT" | grep -q "Error: No response while trying to communicate with the device."; then
    echo "DEBUG: flashgbx restore communication failure. Killing process and exiting with code 2." | tee -a "$LOGFILE"
    pkill -f "flashgbx"
    exit 2
elif echo "$OUTPUT" | grep -q "Couldn’t find file “modified.sav”."; then
    echo "DEBUG: flashgbx could not find modified.sav during restore. Exiting with code 5." | tee -a "$LOGFILE"
    exit 5
elif echo "$OUTPUT" | grep -q "The save data was restored!" && [[ $RETVAL -eq 0 ]]; then
    echo "Save restore complete." | tee -a "$LOGFILE"
    exit 0
else
    echo "DEBUG: Unknown restore error. Output did not match expected patterns. Exiting with code 3." | tee -a "$LOGFILE"
    exit 3
fi