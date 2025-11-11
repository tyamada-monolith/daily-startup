#!/usr/bin/env bash
set -Eeuo pipefail

# --- 基本 ---
DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"

# --- OS/環境 判定ヘルパ ---
is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]] && ! is_wsl; }

# --- OS/環境 判定ヘルパ ---
is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]] && ! is_wsl; }
is_windows_native() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

open_url() {
  local url="$1"

  # --- WSL: PowerShell最優先（URLに&等があっても安全） ---
  if is_wsl; then
    if command -v powershell.exe >/dev/null 2>&1; then
      powershell.exe -NoLogo -NoProfile -Command "Start-Process \"$url\"" >/dev/null 2>&1 &
      return 0
    fi
    if command -v cmd.exe >/dev/null 2>&1; then
      # cmdは&や()に弱いのでpowershellが無い時だけフォールバック
      cmd.exe /c start "" "$url" >/dev/null 2>&1 &
      return 0
    fi
    # （任意）wslu入っていればこちらでもOK
    if command -v wslview >/dev/null 2>&1; then
      wslview "$url" >/dev/null 2>&1 &
      return 0
    fi
  fi

  # --- Windowsネイティブ（Git Bash/MSYS/Cygwin） ---
  if is_windows_native; then
    if command -v powershell.exe >/dev/null 2>&1; then
      powershell.exe -NoLogo -NoProfile -Command "Start-Process \"$url\"" >/dev/null 2>&1 &
      return 0
    fi
    if command -v cmd.exe >/dev/null 2>&1; then
      cmd.exe /c start "" "$url" >/dev/null 2>&1 &
      return 0
    fi
    if command -v explorer.exe >/dev/null 2>&1; then
      explorer.exe "$url" >/dev/null 2>&1 &
      return 0
    fi
  fi

  # --- macOS ---
  if is_macos && command -v open >/dev/null 2>&1; then
    open "$url" >/dev/null 2>&1 &
    return 0
  fi

  # --- Linux ---
  if is_linux; then
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$url" >/dev/null 2>&1 &
      return 0
    fi
    if command -v gio >/dev/null 2>&1; then
      gio open "$url" >/dev/null 2>&1 &
      return 0
    fi
  fi

  echo "URLを開けるコマンドが見つかりません: $url" >&2
}


open_code() {
  # VSCode（code）があればリポジトリを開く
  if command -v code >/dev/null 2>&1; then
    code "$REPO_ROOT"
  fi
}

# --- 1) 今日のファイル作成（パスを受け取る） ---
TODAY_FILE="$("$DIR/daily.sh")"

# --- 2) エディタで開く（あれば） ---
open_code
# 少し待つと同じウィンドウにタブで開きやすい（環境差軽減）
sleep 0.4
if command -v code >/dev/null 2>&1; then
  code -r -g "$TODAY_FILE"
fi

# --- 3) URLを開く ---
# 優先: urls.local.txt（個人用）→ なければ urls.txt（共有）
URL_FILE=""
if [[ -f "$REPO_ROOT/urls.local.txt" ]]; then
  URL_FILE="$REPO_ROOT/urls.local.txt"
elif [[ -f "$REPO_ROOT/urls.txt" ]]; then
  URL_FILE="$REPO_ROOT/urls.txt"
fi

if [[ -n "$URL_FILE" ]]; then
  while IFS= read -r line || [[ -n "${line:-}" ]]; do
    # コメント/空行除去（行内コメントOK）
    line="${line%%#*}"
    line="${line%$'\r'}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    open_url "$line"
  done < "$URL_FILE"
fi

