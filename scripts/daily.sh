#!/usr/bin/env bash
set -Eeuo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"

TODAY_YMD="$(date "+%Y-%m-%d")"
TODAY_Y="$(date "+%Y")"

OUT_DIR="$REPO_ROOT/notes/daily/$TODAY_Y"
OUT_FILE="$OUT_DIR/$TODAY_YMD.md"
TEMPLATE="$REPO_ROOT/templates/daily-template.md"

mkdir -p "$OUT_DIR"

if [[ ! -f "$OUT_FILE" ]]; then
  if [[ -f "$TEMPLATE" ]]; then
    # 1行目のタイトルだけ日付に差し替える
    sed "1s/^# .*/# ${TODAY_YMD} 日報/" "$TEMPLATE" > "$OUT_FILE"
  else
    # テンプレがなければ最小構成で作成
    cat > "$OUT_FILE" <<EOF
# ${TODAY_YMD} 日報

## 今日やること
- 

## メモ
- 

## 明日やること
- 
EOF
  fi
fi

echo "$OUT_FILE"
