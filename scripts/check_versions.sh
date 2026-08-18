#!/bin/bash
#
# Version Consistency Checker
#
# Version.xcconfig (single source of truth) と CHANGELOG.md のバージョンが一致しているかチェックします。
# podspec と xcodeproj は Version.xcconfig から導出されるため、チェック対象は xcconfig のみです。
#
# Usage:
#   bash scripts/check_versions.sh
#

set -euo pipefail

cd "$(dirname "$0")/.."

MODULES=(
  "KarteCore"
  "KarteUtilities"
  "KarteInAppMessaging"
  "KarteRemoteNotification"
  "KarteVariables"
  "KarteVisualTracking"
  "KarteCrashReporting"
  "KarteInAppFrame"
  "KarteDebugger"
  "KarteNotificationServiceExtension"
)
# CHANGELOG のバージョンチェック対象外のモジュール
EXCLUDED=("KarteInbox")

CHANGELOG="CHANGELOG.md"
ERRORS=0

# Version.xcconfig から MARKETING_VERSION を読み取る
read_xcconfig_version() {
  grep -E '^[[:space:]]*MARKETING_VERSION[[:space:]]*=' "$1" \
    | head -1 | sed -E 's/^[^=]*=[[:space:]]*//' | tr -d '[:space:]'
}

# CHANGELOG 最新バージョン表から指定モジュールのバージョンを取得する
# 対象行: | KarteCore | ... | 2.37.0 |
changelog_table_version() {
  grep -E "^\|[[:space:]]*$1[[:space:]]*\|" "$CHANGELOG" \
    | head -1 | sed -E 's/.*\|[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)[[:space:]]*\|[[:space:]]*$/\1/'
}

# CHANGELOG の次回リリースセクション (# Releases - xxxx.xx.xx) 内の
# ### <ShortName> X.Y.Z から指定モジュールのバージョンを取得する
changelog_release_version() {
  local short="${1#Karte}"
  awk -v short="$short" '
    /^#[[:space:]]+Releases[[:space:]]+-[[:space:]]+xxxx\.xx\.xx/ { inSec=1; next }
    inSec && /^#[[:space:]]+Releases[[:space:]]+-[[:space:]]+[0-9]{4}\.[0-9]{2}\.[0-9]{2}/ { exit }
    inSec {
      pat = "^###[[:space:]]+" short "[[:space:]]+[0-9]+\\.[0-9]+\\.[0-9]+"
      if ($0 ~ pat) {
        match($0, /[0-9]+\.[0-9]+\.[0-9]+/)
        print substr($0, RSTART, RLENGTH)
        exit
      }
    }
  ' "$CHANGELOG"
}

is_excluded() {
  for e in "${EXCLUDED[@]}"; do
    [ "$e" = "$1" ] && return 0
  done
  return 1
}

for m in "${MODULES[@]}"; do
  is_excluded "$m" && continue

  xc="$m/Version.xcconfig"
  if [ ! -f "$xc" ]; then
    echo "❌ $m: $xc が見つかりません"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  xcver="$(read_xcconfig_version "$xc")"
  if [ -z "$xcver" ]; then
    echo "❌ $m: Version.xcconfig の MARKETING_VERSION を読み取れません"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  tblver="$(changelog_table_version "$m")"
  if [ -z "$tblver" ]; then
    echo "❌ $m: CHANGELOG.md の最新バージョン表にエントリがありません"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  if [ "$xcver" != "$tblver" ]; then
    echo "❌ $m: バージョン不一致 (Version.xcconfig: $xcver, CHANGELOG表: $tblver)"
    ERRORS=$((ERRORS + 1))
  fi

  # 次回リリースセクションは任意。存在する場合のみ照合する
  relver="$(changelog_release_version "$m")"
  if [ -n "$relver" ] && [ "$relver" != "$xcver" ]; then
    echo "❌ $m: バージョン不一致 (Version.xcconfig: $xcver, CHANGELOGリリース: $relver)"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ "$ERRORS" -ne 0 ]; then
  echo ""
  echo "⚠️ Version.xcconfig と CHANGELOG.md のバージョンが一致していません。各モジュールのバージョン更新には bash scripts/bump_version.sh を使用してください。"
  exit 1
fi

echo "✅ すべてのモジュールで Version.xcconfig と CHANGELOG.md のバージョンが一致しています。"
