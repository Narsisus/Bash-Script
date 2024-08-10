#!/bin/bash

read -p "Enter user name: " username

output_file="speedtest${user_name}.csv"

if [ ! -f "$output_file" ]; then
    echo "Date,Time,Server ID,Server Name,Latency,Download (Mbps),Upload (Mbps)" > "$output_file"
fi

server_list=$(speedtest-cli --list | tail -n +2)

while IFS= read -r line; do

    server_id=$(echo "$line" | awk -F')' '{print $1}' | xargs)
    server_name=$(echo "$line" | cut -d')' -f2 | xargs)

    if [[ $server_id =~ ^[0-9]+$ ]]; then
        echo "Testing $server_name (ID: $server_id)..."

        result=$(speedtest-cli --server "$server_id" --csv 2>/dev/null)

        if [[ $? -eq 0 ]]; then
            current_date=$(date +"%Y-%m-%d")
            current_time=$(date +"%H:%M:%S")

            echo "$current_date,$current_time,$result" >> "$output_file"
            echo "Result for server $server_id appended to $output_file"
        else
            echo "Speedtest failed for server $server_id"
        fi
    fi
done <<< "$server_list"

echo "Speed test results saved to $output_file"
