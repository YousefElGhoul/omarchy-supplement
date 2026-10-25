# Supplement

Personal Omarchy setup:

```bash
./scripts/setup.sh --dry-run
./scripts/setup.sh
```

Omarchy apps install first. After selected packages verify as installed, setup
offers to remove packages listed in `scripts/packages/unwanted.txt`. Back up
Stow conflicts before retrying; setup never adopts them.
