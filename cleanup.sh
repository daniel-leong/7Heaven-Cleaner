#!/bin/bash

# Enhanced System Cleanup Script with Before/After Disk Usage Analysis
# Created: $(date)

echo "=================================================="
echo "🧹 SYSTEM CLEANUP SCRIPT"
echo "=================================================="
echo "Starting comprehensive system cleanup..."
echo ""

# Function to get disk usage in bytes for calculations
get_disk_usage_bytes() {
    df / --output=used --block-size=1 | tail -n 1 | tr -d ' '
}

# Function to display disk usage in human readable format
show_disk_usage() {
    echo "📊 Current Disk Usage:"
    df -h / | grep -E "(Filesystem|/dev/)"
    echo ""
}

# Function to calculate and display space freed
calculate_space_freed() {
    local before=$1
    local after=$2
    local freed=$((before - after))
    local freed_mb=$((freed / 1024 / 1024))
    local freed_gb=$((freed_mb / 1024))
    
    if [ $freed_gb -gt 0 ]; then
        echo "💾 Space freed: ${freed_gb}.$(((freed_mb % 1024) * 100 / 1024))GB (${freed_mb}MB)"
    elif [ $freed_mb -gt 0 ]; then
        echo "💾 Space freed: ${freed_mb}MB"
    else
        local freed_kb=$((freed / 1024))
        echo "💾 Space freed: ${freed_kb}KB"
    fi
    echo ""
}

# Step 0: Initial disk usage scan
echo "🔍 STEP 0: Scanning initial disk usage..."
show_disk_usage
INITIAL_USAGE=$(get_disk_usage_bytes)
echo "Initial disk usage: $INITIAL_USAGE bytes"
echo ""

# Step 1: Docker cleanup
echo "🐳 STEP 1: Cleaning Docker system..."
echo "Current Docker usage:"
sudo docker system df
echo ""
echo "Cleaning unused Docker images, containers, networks, and build cache..."
sudo docker system prune -a --force
echo "✅ Docker cleanup completed"
echo ""

# Step 2: Truncate large active logs
echo "📝 STEP 2: Truncating large active logs..."
echo "Truncating supervisor log..."
if [ -f /var/log/supervisor/supervisord.log ]; then
    SUPERVISOR_SIZE=$(sudo du -sh /var/log/supervisor/supervisord.log | cut -f1)
    echo "  - supervisor log size before: $SUPERVISOR_SIZE"
    sudo truncate -s 0 /var/log/supervisor/supervisord.log
    echo "  - supervisor log truncated ✅"
else
    echo "  - supervisor log not found, skipping"
fi

# echo "Truncating rclone log..."
# if [ -f /var/log/rclone_UNGG.log ]; then
#     RCLONE_SIZE=$(sudo du -sh /var/log/rclone_UNGG.log | cut -f1)
#     echo "  - rclone log size before: $RCLONE_SIZE"
#     sudo truncate -s 0 /var/log/rclone_UNGG.log
#     echo "  - rclone log truncated ✅"
# else
#     echo "  - rclone log not found, skipping"
# fi
# echo "✅ Log truncation completed"
# echo ""

# Step 3: Remove old compressed logs
echo "🗜️ STEP 3: Removing old compressed logs..."
echo "Scanning for compressed logs older than 30 days..."
COMPRESSED_LOGS=$(sudo find /var/log -name "*.gz" -type f -mtime +30 2>/dev/null | wc -l)
if [ $COMPRESSED_LOGS -gt 0 ]; then
    echo "Found $COMPRESSED_LOGS compressed log files to remove"
    sudo find /var/log -name "*.gz" -type f -mtime +30 -delete 2>/dev/null
    echo "✅ Removed old compressed logs"
else
    echo "No old compressed logs found to remove"
fi
echo ""

# Step 4: Clean system journals
echo "📰 STEP 4: Cleaning system journals..."
echo "Current journal usage:"
sudo journalctl --disk-usage
echo "Cleaning journals (keeping 1 week)..."
sudo journalctl --vacuum-time=1w
echo "New journal usage:"
sudo journalctl --disk-usage
echo "✅ Journal cleanup completed"
echo ""

# Step 5: APT cleanup
echo "📦 STEP 5: Cleaning APT packages..."
echo "Removing unused packages..."
sudo apt autoremove --purge -y
echo "Cleaning package cache..."
sudo apt autoclean
echo "✅ APT cleanup completed"
echo ""
sudo apt clean
echo "🧹 APT cleansing completed"
echo ""

# Step 6: Clean old kernel configs
echo "🔧 STEP 6: Cleaning old kernel configurations..."
OLD_KERNELS=$(dpkg -l | grep '^rc' | grep linux | wc -l)
if [ $OLD_KERNELS -gt 0 ]; then
    echo "Found $OLD_KERNELS old kernel configuration entries to purge"
    sudo dpkg --purge $(dpkg -l | grep '^rc' | grep linux | awk '{print $2}') 2>/dev/null
    echo "✅ Old kernel configs purged"
else
    echo "No old kernel configurations found"
fi
echo ""

# Step 7: Clean temporary files
echo "🗑️ STEP 7: Cleaning temporary files..."
echo "Removing temporary files older than 7 days..."
TEMP_FILES=$(sudo find /tmp -type f -atime +7 2>/dev/null | wc -l)
if [ $TEMP_FILES -gt 0 ]; then
    echo "Found $TEMP_FILES temporary files to remove"
    sudo find /tmp -type f -atime +7 -delete 2>/dev/null
    echo "✅ Temporary files cleaned"
else
    echo "No old temporary files found"
fi
echo ""

# Final disk usage scan
echo "🔍 FINAL SCAN: Analyzing disk usage after cleanup..."
show_disk_usage
FINAL_USAGE=$(get_disk_usage_bytes)
echo "Final disk usage: $FINAL_USAGE bytes"
echo ""

# Calculate and display results
echo "=================================================="
echo "🎉 CLEANUP SUMMARY"
echo "=================================================="
calculate_space_freed $INITIAL_USAGE $FINAL_USAGE

# Show top disk usage after cleanup
echo "📊 Top disk usage after cleanup:"
sudo du -hx --max-depth=2 / 2>/dev/null | grep -E '^[0-9.]+[GM]' | sort -rh | head -10
echo ""

echo "✅ System cleanup completed successfully!"
echo "=================================================="

# Optional: Show recommendations for large directories
echo ""
echo "💡 RECOMMENDATIONS:"
echo "   - Monitor /mnt/vfs-cache (5.1GB) - RClone cache directory"
echo "   - Consider cleaning Docker if it grows beyond 10GB"
echo "   - Set up log rotation for large application logs"
echo ""
