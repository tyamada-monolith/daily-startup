#!/usr/bin/env python3
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent


def create_daily_file() -> Path:
    today = datetime.now()
    today_ymd = today.strftime("%Y-%m-%d")
    year = today.strftime("%Y")

    out_dir = REPO_ROOT / "notes" / "daily" / year
    out_file = out_dir / f"{today_ymd}.md"
    template = REPO_ROOT / "templates" / "daily-template.md"

    out_dir.mkdir(parents=True, exist_ok=True)

    if not out_file.exists():
        if template.exists():
            lines = template.read_text(encoding="utf-8").splitlines(True)
            if lines:
                lines[0] = f"# {today_ymd} 日報\n"
            out_file.write_text("".join(lines), encoding="utf-8")
        else:
            out_file.write_text(
                f"""# {today_ymd} 日報

## 今日やること
- 

## メモ
- 

## 明日やること
- 
""",
                encoding="utf-8",
            )

    return out_file
