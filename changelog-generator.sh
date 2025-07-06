#!/bin/bash
output_file="changelog_$(date +%Y%m%d).md"

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo to ensure proper package information access"
    exit 1
fi

echo "Updating package lists..."
apt update >/dev/null 2>&1 || { echo "Failed to update package lists"; exit 1; }

echo "# Package Changelog - Generated on $(date '+%Y-%m-%d %H:%M:%S')" > "$output_file"
echo "" >> "$output_file"

upgradable_count=0
apt list --upgradable 2>/dev/null | tail -n +2 | while read -r line; do
    package=$(echo "$line" | cut -d'/' -f1)
    versions=$(echo "$line" | grep -oP '\K[^,]+(?=\s+\w+\s+\[\w+\]$)')
    # We could also use awk: current_version=$(echo "$line" | awk '{print $2}')
    
    echo "* **$package** \`$versions\`" >> "$output_file"
    ((upgradable_count++))
done

echo "Changelog saved: $output_file"
echo "Upgradable packages: $(wc -l < "$output_file" | awk '{print $1-2}')"
