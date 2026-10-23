#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 unsigned.dmg signed.dmg" >&2
  exit 2
fi

input=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
output=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
identity=$(security find-identity -v -p codesigning | awk -F '"' '/Developer ID Application:.*2B6746PVGB/ { print $2; exit }')
test -n "$identity"
root_dir=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d /private/tmp/nizlo-remote-sign.XXXXXX)
mounted=0
cleanup() {
  if [ "$mounted" -eq 1 ]; then hdiutil detach "$work/mount" -quiet || true; fi
  rm -rf "$work"
}
trap cleanup EXIT

test -f "$input"
test ! -e "$output"
mkdir -p "$work/mount" "$work/stage"
hdiutil attach -readonly -nobrowse -quiet -mountpoint "$work/mount" "$input"
mounted=1
test -d "$work/mount/NizloRemote.app"
/usr/bin/ditto "$work/mount/NizloRemote.app" "$work/stage/NizloRemote.app"
hdiutil detach "$work/mount" -quiet
mounted=0

app="$work/stage/NizloRemote.app"
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")
test "$bundle_id" = com.nizlo.remote.client
test -f "$app/Contents/MacOS/service"
bash "$root_dir/.github/scripts/sign-macos-app.sh" "$app" "$identity" "$root_dir/flutter/macos/Runner/Release.entitlements"
codesign --verify --deep --strict -R='anchor apple generic and certificate leaf[subject.OU] = "2B6746PVGB" and identifier "com.nizlo.remote.client"' "$app"

ln -s /Applications "$work/stage/Applications"
hdiutil create -quiet -ov -format UDZO -volname 'Nizlo Remote' -srcfolder "$work/stage" "$output"
xcrun notarytool submit "$output" --keychain-profile nizlo-notary --wait
xcrun stapler staple "$output"
xcrun stapler validate "$output"
shasum -a 256 "$output" > "$output.sha256"
echo "Signed and notarized: $output"
