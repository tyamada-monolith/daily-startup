#!/usr/bin/env python3
import os
import subprocess
import time
import shutil
from pathlib import Path

from daily import create_daily_file
from urls import open_url_grouped_with_chrome


def open_vscode(today_file: Path | None) -> None:
    code_path = shutil.which("code")
    if not code_path:
        return

    print("=== VSCode起動中 ===")

    workspace = os.environ.get("WORKSPACE", str(Path.home()))
    try:
        subprocess.Popen(
            [code_path, workspace],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass

    time.sleep(0.4)

    if today_file:
        try:
            subprocess.Popen(
                [code_path, "-r", "-g", str(today_file)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception:
            pass


def main() -> None:
    print("=== デイリーファイル作成中 ===")
    today_file = create_daily_file()
    if today_file:
        print(f"  ✓ {today_file}")

    open_vscode(today_file)
    open_url_grouped_with_chrome()


if __name__ == "__main__":
    main()
