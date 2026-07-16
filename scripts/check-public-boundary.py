#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
from pathlib import Path

FORBIDDEN_PATHS = (
    "fleet-inventory",
    "next-session-handoff",
    "tailscale-policy.hujson",
    "runtime-state",
)
FORBIDDEN_CONTENT = {
    "tailnet hostname": re.compile(r"\b[a-z0-9-]+\.tail[a-z0-9]+\.ts\.net\b", re.I),
    "tailscale address": re.compile(r"\b100\.(?:\d{1,3}\.){2}\d{1,3}\b"),
    "private key": re.compile(r"-----BEGIN (?:OPENSSH|RSA|EC|DSA) PRIVATE KEY-----"),
    "docker tcp relay": re.compile("portainer" + "_docker_relay", re.I),
}
TEXT_SUFFIXES = {".md", ".txt", ".json", ".yaml", ".yml", ".toml", ".hujson", ".py"}


def tracked_files() -> list[Path]:
    result = subprocess.run(["git", "ls-files", "-z"], capture_output=True, check=True)
    return [Path(item.decode()) for item in result.stdout.split(b"\0") if item]


def main() -> int:
    errors: list[str] = []
    for path in tracked_files():
        normalized = path.as_posix().lower()
        if any(fragment in normalized for fragment in FORBIDDEN_PATHS):
            errors.append(f"forbidden public path: {path}")
        if path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for label, pattern in FORBIDDEN_CONTENT.items():
            if pattern.search(text):
                errors.append(f"{label} found in {path}")
    if errors:
        print("\n".join(errors))
        return 1
    print("Public repository boundary checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
