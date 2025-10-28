#!/usr/bin/env bash
# dotlink.sh - Package-based symlink installer (stow風)
#  - パッケージ: ディレクトリ名（例: zsh, git, nvim）
#  - プラットフォーム差分: <pkg>-macos / <pkg>-linux を自動で併用
#  - 動作: リポジトリ内のファイル・シンボリックリンクを $TARGET に ln -sfn で張る
#  - 解除: --unlink 時は「自分が張ったリンクのみ」安全に削除

set -euo pipefail

# ===== Config =====
TARGET="${HOME}"
REPO="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *) echo "Unsupported OS: $OS" >&2; exit 2 ;;
esac

DRY_RUN=0
UNLINK=0
VERBOSE=0
BACKUP=0   # 既存の実体ファイルがある場合に .bak 退避したいなら 1 に変更 or --backup で有効化
CLEANUP_EMPTY_DIRS=0   # unlink 時に空のディレクトリを削除する場合は 1 に変更 or --cleanup-empty-dirs で有効化

# 無視するパス（findの-prune用）
IGNORES=(
  ".git"
  ".github"
  ".stow-local-ignore"
  ".DS_Store"
  "README*"
  "LICENSE*"
)

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options] <pkg> [<pkg>...]
Options:
  --dry-run              Show planned changes without making them
  --unlink               Remove symlinks for specified packages (only those created by this script)
  --verbose              Show detailed output
  --target DIR           Target directory for installation (default: $HOME)
  --backup               Backup existing regular files to *.bak before replacing
  --cleanup-empty-dirs   Remove empty directories after unlinking
Examples:
  $(basename "$0") zsh git
  $(basename "$0") --dry-run nvim
  $(basename "$0") --unlink --cleanup-empty-dirs zsh
USAGE
}

log() { [ "$VERBOSE" -eq 1 ] && echo "$@"; }
act() { [ "$DRY_RUN" -eq 1 ] && echo "(dry-run) $*" || eval "$@"; }

# 引数処理
ARGS=()
while (( "$#" )); do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --unlink)  UNLINK=1 ;;
    --verbose) VERBOSE=1 ;;
    --backup)  BACKUP=1 ;;
    --cleanup-empty-dirs) CLEANUP_EMPTY_DIRS=1 ;;
    --target)  shift; TARGET="${1:-}"; [ -z "$TARGET" ] && { echo "--target requires DIR" >&2; exit 2; } ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *)  ARGS+=("$1") ;;
  esac
  shift
done
[ "${#ARGS[@]}" -eq 0 ] && { usage; exit 2; }

# パッケージから適用ディレクトリ候補を組み立てる（順序: base -> platform）
packages_to_dirs() {
  local pkg="$1"
  local dirs=()
  [ -d "${REPO}/${pkg}" ] && dirs+=("${pkg}")
  [ -d "${REPO}/${pkg}-${PLATFORM}" ] && dirs+=("${pkg}-${PLATFORM}")
  if [ "${#dirs[@]}" -eq 0 ]; then
    echo "Package not found: ${pkg} (checked: ${pkg}, ${pkg}-${PLATFORM})" >&2
    return 1
  fi
  printf "%s\n" "${dirs[@]}"
}

# 無視判定
should_prune() {
  local rel="$1"
  for pat in "${IGNORES[@]}"; do
    # シェルグロブで判定（find の -name 相当）
    case "$rel" in
      */$pat|$pat) return 0 ;;
    esac
  done
  return 1
}

# 空のディレクトリを再帰的に削除（親ディレクトリも空なら削除）
cleanup_empty_dir() {
  local dir="$1"

  # TARGET配下でない場合は削除しない（安全性チェック）
  case "$dir" in
    "$TARGET"/*) ;;
    "$TARGET") return ;;  # TARGET自体は削除しない
    *) log "skip cleanup (outside TARGET): $dir"; return ;;
  esac

  # ディレクトリが存在しない、またはシンボリックリンクの場合は何もしない
  [ -d "$dir" ] || return
  [ -L "$dir" ] && return

  # ディレクトリが空かチェック
  if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
    echo "cleanup: $dir (empty directory)"
    if [ "$DRY_RUN" -eq 0 ]; then
      rmdir -- "$dir"
    else
      echo "(dry-run) rmdir -- \"$dir\""
    fi

    # 親ディレクトリも再帰的にチェック
    local parent
    parent="$(dirname "$dir")"
    if [ "$parent" != "$TARGET" ] && [ "$parent" != "/" ]; then
      cleanup_empty_dir "$parent"
    fi
  else
    log "skip cleanup (not empty): $dir"
  fi
}

# 1ファイルをリンク or アンリンク
process_one() {
  local src="$1"   # 絶対パス（REPO配下）
  local rel="$2"   # REPO内での相対パス（package名を除いた相対）
  local dst="$3"   # 絶対パス（TARGET配下）

  if [ "$UNLINK" -eq 1 ]; then
    # 自分が張ったリンクだけ外す
    if [ -L "$dst" ]; then
      local cur
      cur="$(readlink "$dst" || true)"
      if [ "$cur" = "$src" ]; then
        echo "unlink: $dst"
        if [ "$DRY_RUN" -eq 0 ]; then
          rm -f -- "$dst"
        else
          echo "(dry-run) rm -f -- \"$dst\""
        fi

        # オプションが有効な場合、空のディレクトリをクリーンアップ
        if [ "$CLEANUP_EMPTY_DIRS" -eq 1 ]; then
          local parent_dir
          parent_dir="$(dirname "$dst")"
          cleanup_empty_dir "$parent_dir"
        fi
      else
        log "skip (not ours): $dst -> $cur"
      fi
    else
      log "skip (not a symlink): $dst"
    fi
    return
  fi

  # リンク作成
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$dst")"
  else
    echo "(dry-run) mkdir -p \"$(dirname "$dst")\""
  fi

  # 既存が実体ファイルで、置換したい場合の退避
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    if [ "$BACKUP" -eq 1 ]; then
      local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
      echo "backup: $dst -> $bak"
      if [ "$DRY_RUN" -eq 0 ]; then
        mv -- "$dst" "$bak"
      else
        echo "(dry-run) mv -- \"$dst\" \"$bak\""
      fi
    fi
  fi

  echo "link: $dst -> $src"
  if [ "$DRY_RUN" -eq 0 ]; then
    ln -sfn -- "$src" "$dst"
  else
    echo "(dry-run) ln -sfn -- \"$src\" \"$dst\""
  fi
}

# メイン
for pkg in "${ARGS[@]}"; do
  # mapfile -t dirs < <(packages_to_dirs "$pkg") || exit 1 # bash 4.0+
  dirs=()
  while IFS= read -r line; do
    dirs+=("$line")
  done < <(packages_to_dirs "$pkg") || exit 1
  for d in "${dirs[@]}"; do
    log "processing package: $d"
    (
      cd "${REPO}/${d}"

      # find: ファイルとシンボリックリンクを対象（ディレクトリは作成のみ）
      while IFS= read -r -d '' path; do
        rel="${path#./}"                               # パッケージ直下からの相対
        if should_prune "$rel"; then
          log "prune: $rel"
          continue
        fi
        src="${REPO}/${d}/${rel}"
        dst="${TARGET}/${rel}"
        process_one "$src" "$rel" "$dst"
      done < <(find . -mindepth 1 \( -type f -o -type l \) -print0)
    )
  done
done
