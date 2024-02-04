#!/bin/bash

# Prep data for mod
backupLogs="/home/steam/logs/*/Pavlov/Saved/Logs/*.log"
liveLogs="/home/steam/*/Pavlov/Saved/Logs/*.log"
out="/home/steam/pavlovserver006/Pavlov/Saved/Config/ModSave/"

# Function to convert text data to JSON using Python
process_to_json() {
    local input_file=$1
    local output_file=$2

    python3 - <<END
import json

with open("${input_file}", "r") as file:
    text = file.read()

lines = text.strip().split('\n')
data = {}

for line in lines:
    parts = line.split()
    if len(parts) == 2:
        kills, steam_id = parts
        data[steam_id] = int(kills)

json_data = json.dumps(data, indent=4)

with open("${output_file}", "w") as json_file:
    json_file.write(json_data)
END
}

# Process logs and convert to JSON
# For total kills
cat "${liveLogs}" "${backupLogs}" | grep '"Killer":' | cut -d'"' -f 4 | sort -n | wc -l | jq . > "${out}stats-allkills.json"
process_to_json "${out}stats-allkills.json" "${out}json-allkills.json"

# For kills
cat "${liveLogs}" "${backupLogs}" | grep '"Killer":' | cut -d'"' -f 4 | sort -n | uniq -c | sort -n | tac > "${out}stats-kills.txt"
process_to_json "${out}stats-kills.txt" "${out}json-kills.json"

# For deaths
cat "${liveLogs}" "${backupLogs}" | grep '"Killed":' | cut -d'"' -f 4 | sort -n | uniq -c | sort -n | tac > "${out}stats-deaths.txt"
process_to_json "${out}stats-deaths.txt" "${out}json-deaths.json"

# For guns
cat "${liveLogs}" "${backupLogs}" | grep '"KilledBy":' | tr -d - | cut -d '"' -f 4 | sort | uniq -c | sort -n > "${out}stats-guns.txt"
process_to_json "${out}stats-guns.txt" "${out}json-guns.json"


#move all old live logs to backup if u dont do this pavlov will purge the old logs every so often 
ls -R -D /home/steam/pavlovserver*/Pavlov/Saved/Logs/Pavlov-backup*.log | xargs -I% mv % /home/steam/logs/
