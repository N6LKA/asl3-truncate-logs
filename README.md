# asl3-truncate-logs

A simple bash script for [ASL3](https://allstarlink.org/) (AllStar Link 3) systems that monitors selected log files and truncates them when they exceed a defined size. Keeps the most recent data and logs the action to syslog. Designed to run via cron or manually.

---

## Requirements

- ASL3 installed and configured
- `bash`, `tail`, `wc`, `logger` — standard on all Linux systems

---

## Installation & Updates

Run the following command as root or with sudo for both fresh installs and updates:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/N6LKA/asl3-truncate-logs/main/install.sh)
```

Installs `truncate_logs.sh` to `/etc/asterisk/scripts/`, sets ownership to `root:asterisk`, and makes it executable.

**Existing install detected:** The installer automatically backs up the existing script, downloads the latest version, and removes the backup on success.

---

## Usage

### Run Manually

```bash
/etc/asterisk/scripts/truncate_logs.sh
```

### Schedule with Cron

Add a cron entry to run automatically. The example below runs weekly on Sundays at 4:05 AM:

```
05 04 * * 0 /etc/asterisk/scripts/truncate_logs.sh
```

Edit your crontab with:

```bash
crontab -e
```

---

## Monitored Files

The following log files are monitored by default. Edit `truncate_logs.sh` to add, remove, or adjust limits.

| File | Max Size |
|------|----------|
| `/var/log/asterisk/messages.log` | 300,000 bytes |
| `/var/log/asterisk/connections.log` | 100,000 bytes |
| `/var/log/apache2/access.log` | 300,000 bytes |
| `/var/log/apache2/error.log` | 20,000 bytes |

> **Note:** If you are using [asl3-connection-log](https://github.com/N6LKA/asl3-connection-log), verify that the connection log path matches. That project writes to `/var/log/asterisk/connectlog` (no `.log` extension).

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
