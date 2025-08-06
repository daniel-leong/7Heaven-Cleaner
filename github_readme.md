# System Cleanup Script 🧹

A comprehensive bash script for automated Linux system cleanup with detailed disk usage analysis and space recovery reporting.

## Features

- **Docker Cleanup** - Removes unused images, containers, networks, and build cache
- **Log Management** - Truncates large active logs and removes old compressed logs (30+ days)
- **System Journals** - Cleans systemd journals (keeps 1 week)
- **Package Cleanup** - Removes unused APT packages and cleans cache
- **Kernel Cleanup** - Purges old kernel configuration entries
- **Temporary Files** - Removes temp files older than 7 days
- **Detailed Analysis** - Shows before/after disk usage and space freed

## Requirements

- Linux system (Ubuntu/Debian tested)
- sudo privileges
- Docker (optional - script will skip if not present)

## Installation

```bash
# Download the script
wget https://raw.githubusercontent.com/yourusername/system-cleanup/main/cleanup.sh

# Make it executable
chmod +x cleanup.sh
```

## Usage

```bash
# Run the cleanup script
sudo ./cleanup.sh
```

## Sample Output

```
🧹 SYSTEM CLEANUP SCRIPT
==================================================
🔍 STEP 0: Scanning initial disk usage...
📊 Current Disk Usage:
/dev/sda1       50G   35G   13G  74% /

🐳 STEP 1: Cleaning Docker system...
🗜️ STEP 3: Removing old compressed logs...
📰 STEP 4: Cleaning system journals...
📦 STEP 5: Cleaning APT packages...

🎉 CLEANUP SUMMARY
==================================================
💾 Space freed: 2.5GB (2560MB)
```

## What Gets Cleaned

### Safe Operations
- Unused Docker resources
- Old compressed log files (30+ days)
- System journal entries (keeps 1 week)
- Unused APT packages
- Old kernel configurations
- Temporary files (7+ days old)
- Large active logs (truncated, not deleted)

### What's Preserved
- Active system logs (truncated but not deleted)
- Current packages and dependencies
- Recent temporary files
- User data and configurations

## Safety Features

- **Read-only scanning** before making changes
- **Detailed reporting** of what will be removed
- **Graceful error handling** for missing files/services
- **Conservative timeouts** (7-30 days) for file removal
- **Preserves active logs** by truncating instead of deleting

## Customization

Edit these variables in the script to adjust cleanup behavior:

```bash
# Log retention (days)
COMPRESSED_LOG_DAYS=30
TEMP_FILE_DAYS=7

# Journal retention
JOURNAL_RETENTION="1w"  # 1 week, can be changed to 1d, 1m, etc.
```

## Recommendations

The script provides recommendations for ongoing maintenance:

- Monitor large directories like `/mnt/vfs-cache`
- Set up automatic log rotation
- Regular Docker cleanup for heavy container usage
- Consider cron job for automated weekly cleanup

## Cron Setup (Optional)

To run automatically every Sunday at 3 AM:

```bash
# Edit crontab
sudo crontab -e

# Add this line
0 3 * * 0 /path/to/cleanup.sh >> /var/log/cleanup.log 2>&1
```

## Troubleshooting

**Permission Issues:**
```bash
# Ensure script has proper permissions
chmod +x cleanup.sh
```

**Docker Issues:**
- Script will skip Docker cleanup if Docker is not installed
- Ensure your user is in the docker group: `sudo usermod -aG docker $USER`

**Space Not Freed:**
- Some processes may need restart to release file handles
- Reboot system if space doesn't appear freed immediately

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new cleanup feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Changelog

### v1.0.0
- Initial release with comprehensive cleanup features
- Docker, logs, journals, packages, and temp file cleanup
- Before/after disk usage analysis
- Detailed progress reporting

## Support

- Create an issue for bug reports
- Star the repo if you find it useful
- Share feedback and suggestions