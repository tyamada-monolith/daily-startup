#!/usr/bin/env bash
set -Eeuo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"

# 出力ディレクトリ（例: notes/daily/2025/）
TODAY_YMD="$(date "+%Y-%m-%d")"
TODAY_Y="$(date "+%Y")"

OUT_DIR="$REPO_ROOT/notes/daily/$TODAY_Y"
OUT_FILE="$OUT_DIR/$TODAY_YMD.md"

mkdir -p "$OUT_DIR"

if [[ ! -f "$OUT_FILE" ]]; then
  cat > "$OUT_FILE" <<EOF
# $TODAY_YMD 日報

## 今日やること
- 

## メモ
- 

## 明日やること
- 
EOF
fi

# 絶対パスを標準出力（呼び元が受け取れるように）
echo "$OUT_FILE"

