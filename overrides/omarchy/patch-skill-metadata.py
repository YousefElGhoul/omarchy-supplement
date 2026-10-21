#!/usr/bin/env python3
"""Set manual-invocation metadata on Omarchy-provided OpenCode skills."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import stat
import tempfile

KEYS = ('  opencode/slash: "true"', '  opencode/autoinvoke: "false"')
SKILLS = ("diagnose-crash", "omarchy")


def patch(text: str, path: Path) -> str:
    if not text.startswith("---\n"):
        raise ValueError(f"missing YAML front matter: {path}")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise ValueError(f"unterminated YAML front matter: {path}")
    front = text[4:end]
    lines = front.splitlines()
    metadata_indices = [i for i, line in enumerate(lines) if re.match(r"^metadata\s*:", line)]
    if len(metadata_indices) > 1:
        raise ValueError(f"ambiguous duplicate metadata blocks: {path}")
    if not metadata_indices:
        lines.extend(["metadata:", *KEYS])
    else:
        start = metadata_indices[0]
        if not re.fullmatch(r"metadata:\s*(?:#.*)?", lines[start]):
            raise ValueError(f"unsupported or malformed metadata mapping: {path}")
        stop = start + 1
        while stop < len(lines) and (not lines[stop].strip() or lines[stop][0].isspace()):
            stop += 1
        block = lines[start + 1 : stop]
        for line in block:
            if line.strip() and not line.lstrip().startswith("#") and not re.match(r"^\s+[^:#][^:]*:\s*", line):
                raise ValueError(f"malformed metadata entry: {path}: {line}")
        for key in ("opencode/slash", "opencode/autoinvoke"):
            found = [i for i, line in enumerate(block) if re.match(rf"^\s*{re.escape(key)}\s*:", line)]
            if len(found) > 1:
                raise ValueError(f"duplicate {key} metadata keys: {path}")
            value = '"true"' if key.endswith("slash") else '"false"'
            replacement = f"  {key}: {value}"
            if found:
                block[found[0]] = replacement
            else:
                block.append(replacement)
        lines[start + 1 : stop] = block
    updated_front = "\n".join(lines)
    return text[:4] + updated_front + text[end:]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("/usr/share/omarchy/default/agents/skills"))
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    changed: list[tuple[Path, str, str]] = []
    for skill in SKILLS:
        path = args.root / skill / "SKILL.md"
        if not path.is_file():
            raise SystemExit(f"Expected Omarchy skill not found: {path}")
        original = path.read_text(encoding="utf-8")
        updated = patch(original, path)
        if original != updated:
            changed.append((path, original, updated))
    if not changed:
        print("Omarchy skill metadata already matches; no files changed.")
        return 0
    for path, _, _ in changed:
        print(f"{'Would update' if args.dry_run else 'Updating'} {path}")
    if args.dry_run:
        return 0
    for path, _, updated in changed:
        mode = stat.S_IMODE(path.stat().st_mode)
        owner = path.stat()
        fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
        try:
            with os.fdopen(fd, "w", encoding="utf-8", newline="") as handle:
                handle.write(updated)
            if (owner.st_uid, owner.st_gid) != (os.geteuid(), os.getegid()):
                os.chown(temp_name, owner.st_uid, owner.st_gid)
            os.chmod(temp_name, mode)
            os.replace(temp_name, path)
        finally:
            if os.path.exists(temp_name):
                os.unlink(temp_name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
