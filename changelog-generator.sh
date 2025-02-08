#!/bin/bash

output_file="changelog_$(date +%Y%m%d).md"

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo to ensure proper package information access"
    exit 1
fi

apt update >/dev/null 2>&1

echo "# Package Changelog - Generated on $(date '+%Y-%m-%d %H:%M:%S')" > "$output_file"
echo "" >> "$output_file"

apt list --installed 2>/dev/null | tail -n +2 | while read -r line; do
    package=$(echo "$line" | cut -d'/' -f1)
    current_version=$(echo "$line" | grep -oP '\K[^,]+(?=\s+\w+\s+\[\w+\]$)')
    
    available_version=$(apt-cache policy "$package" | grep Candidate: | awk '{print $2}')
    
    if [ "$current_version" != "$available_version" ] && [ ! -z "$available_version" ]; then
        echo "* **$package** \`$available_version\` [upgradable from: $current_version]" >> "$output_file"
    fi
done

echo "Changelog has been saved at: $output_file"
echo "Can be upgraded from: $(grep -c "^*" "$output_file")"

head -n 5 "$output_file"
