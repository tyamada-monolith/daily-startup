#!/usr/bin/env python3
import subprocess
import time
from pathlib import Path

URL_GROUP_DELAY = 3
CHROME_PATH = r"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent


def open_url_grouped_with_chrome() -> None:
    url_file = REPO_ROOT / "urls.local.txt"
    if not url_file.exists():
        url_file = REPO_ROOT / "urls.txt"

    if not url_file.exists():
        print("URLファイルが見つかりません")
        return

    print(f"\n=== URL起動開始: {url_file} ===\n")

    if not Path(CHROME_PATH).exists():
        print(f"Chrome が見つかりません: {CHROME_PATH}")
        return

    group_num = 1
    current_group_urls: list[str] = []

    text = url_file.read_text(encoding="utf-8")
    for raw_line in text.splitlines():
        line = raw_line

        stripped = line.lstrip()
        if stripped.startswith("#") or stripped == "":
            continue

        if "#" in line:
            line = line.split("#", 1)[0]

        line = line.strip()
        if not line:
            continue

        if line == "---":
            if current_group_urls:
                print(
                    f"\n━━━ グループ {group_num} を新規ウィンドウで起動 "
                    f"({len(current_group_urls)}件) ━━━"
                )
                cmd = [CHROME_PATH, "--new-window"] + current_group_urls
                subprocess.Popen(
                    cmd,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                time.sleep(URL_GROUP_DELAY)

            group_num += 1
            current_group_urls = []
            continue

        current_group_urls.append(line)

    if current_group_urls:
        print(
            f"\n━━━ グループ {group_num} を新規ウィンドウで起動 "
            f"({len(current_group_urls)}件) ━━━"
        )
        cmd = [CHROME_PATH, "--new-window"] + current_group_urls
        subprocess.Popen(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    print("\n=== 完了 ===")
