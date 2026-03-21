# asl3-truncate-logs

![Release Version](https://img.shields.io/github/v/release/N6LKA/asl3-truncate-logs?label=Version&color=f15d24)
![Release Date](https://img.shields.io/github/release-date/N6LKA/asl3-truncate-logs?label=Released&color=f15d24)
![Hits](https://img.shields.io/endpoint?url=https%3A%2F%2Fhits.dwyl.com%2FN6LKA%2Fasl3-truncate-logs.json&label=Hits&color=f15d24)
![GitHub Repo Size](https://img.shields.io/github/repo-size/N6LKA/asl3-truncate-logs?label=Size&color=f15d24)

A simple bash script for [ASL3](https://allstarlink.org/) (AllStar Link 3) systems that monitors selected log files and truncates them when they exceed a defined size. Keeps the most recent data and logs the action to syslog. Designed to run via cron or manually.

---

## Requirements

- ASL3 installed and configured
- `bash`, `tail`, `wc`, `logger` — standard on all Linux systems

---

## Installation & Updates

Run the following command as root or with sudo for both fresh installs and updates:

```bash
bash <(curl -fsSL -H "Cache-Control: no-cache" https://raw.githubusercontent.com/N6LKA/asl3-truncate-logs/main/install.sh)
```

Installs `truncate_logs.sh` to `/etc/asterisk/scripts/`, sets ownership to `root:asterisk`, and makes it executable.

**Existing install detected:** The installer automatically backs up the existing script, downloads the latest version, and removes the backup on success.

---

## Usage

### Run Manually

```bash
/etc/asterisk/scripts/truncate_logs.sh
```

### Cron Schedule

The installer automatically adds the following entry to the root crontab to run daily at 6:00 AM:

```
#Truncate Logs daily at 06:00. (Do not use if rebooting weekly. Reboot clears all logs.)
00 06 * * * /etc/asterisk/scripts/truncate_logs.sh >/dev/null 2>&1
```

If a cron entry for this script already exists, the installer will update it. To change the schedule:

```bash
crontab -e
```

---

## Monitored Files

The following log files are monitored by default. Edit `truncate_logs.sh` to add, remove, or adjust limits.

| File | Max Size |
|------|----------|
| `/var/log/asterisk/messages.log` | 300,000 bytes |
| `/var/log/asterisk/connectlog` | 100,000 bytes |
| `/var/log/apache2/access.log` | 300,000 bytes |
| `/var/log/apache2/error.log` | 20,000 bytes |

> **Note:** The connection log path (`connectlog`) matches the [asl3-connection-log](https://github.com/N6LKA/asl3-connection-log) project. This path differs from the original HamVoIP filename (`connections.log`).

---

## Adding Files to Monitor

Each monitored file is defined by a four-line block in the script:

```bash
FILE="/path/to/your/file.log"
maximumsize=100000
text_truncate="LOG - Your log size adjusted"
text_ok="LOG - Your log size OK"
truncate_log
```

If a monitored file does not exist, it is silently skipped.

---

## License

MIT License — Copyright 2026 Larry K. Aycock (N6LKA)

See [LICENSE](LICENSE) for details.
