# Supplement

```bash
./scripts/setup.sh [--dry-run] [--no-pkg]
```

Full setup updates the system, installs selected apps, deploys configs, then
removes unwanted packages. `--no-pkg` skips package and plugin operations. Four
known config conflicts are backed up as `.bak`; other Stow conflicts stop
deployment. Backups are never overwritten.
