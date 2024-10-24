#!/bin/bash

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                                                                   $
#    __ _      _             __ _                  _                $
#    / /| |    (_)           / /| |                | |              $
#   / / | |__   _  _ __     / / | |__    __ _  ___ | |__            $
#  / /  | '_ \ | || '_ \   / /  | '_ \  / _` |/ __|| '_ \           $
# / /   | |_) || || | | | / /   | |_) || (_| |\__ \| | | |          $ 
#/_/    |_.__/ |_||_| |_|/_/    |_.__/  \__,_||___/|_| |_|          $
#                                                                   $
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                                                                      

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 file_with_sites"
    exit 1
fi

file=$1

if [ ! -f "$file" ];then
    echo "File not found!"
    exit 1
fi

while IFS= read -r site; do
    ip=$(ping -c 1 "$site" | grep "PING" | awk '{print $3}' | tr -d '()')

    if [ -z "$ip" ]; then
        echo "Failed to resolve IP for $site"
        continue
    fi

    echo "IP for $site is $ip"
    echo "Scanning ports for $ip..."

    open_ports=()
    for port in {1..65535}; do
        timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null && open_ports+=($port)
    done

    if [ ${#open_ports[@]} -gt 0 ]; then
        echo "Open ports for $site ($ip): ${open_ports[*]}"
        echo "Site: $site ($ip)" >> "${site}_open_ports.txt"
        echo "Open ports: ${open_ports[*]}" >> "${site}_open_ports.txt"
        echo "-------------------------------" >> "${site}_open_ports.txt"
    else
        echo "No open ports found for $site ($ip)"
    fi

done < "$file"
