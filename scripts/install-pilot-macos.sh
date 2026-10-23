#!/bin/bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ] || { [ "$#" -eq 2 ] && [ "$2" != "--replace" ]; }; then
  echo "Usage: $0 signed-and-notarized.dmg [--replace]" >&2
  exit 2
fi

input=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
destination=/Applications/NizloRemote.app
stage=/Applications/.NizloRemote.staging.$$
backup=/Applications/.NizloRemote.backup.$(date +%Y%m%d%H%M%S)
work=$(mktemp -d /private/tmp/nizlo-remote-install.XXXXXX)
mounted=0
replaced=0
verified=0
cleanup() {
  if [ "$mounted" -eq 1 ]; then hdiutil detach "$work/mount" -quiet || true; fi
  if [ "$replaced" -eq 1 ] && [ "$verified" -eq 0 ] && [ -e "$backup" ]; then
    if [ -e "$destination" ]; then mv "$destination" "$stage"; fi
    mv "$backup" "$destination"
  fi
  if [ -e "$stage" ]; then rm -rf "$stage"; fi
  rm -rf "$work"
}
trap cleanup EXIT

test -f "$input"
if [ -e "$destination" ]; then
  test "${2:-}" = --replace
  test ! -L "$destination"
  test -d "$destination"
  test "$('/usr/libexec/PlistBuddy' -c 'Print :CFBundleIdentifier' "$destination/Contents/Info.plist")" = com.nizlo.remote.client
  test "$(codesign -dv --verbose=4 "$destination" 2>&1 | sed -n 's/^TeamIdentifier=//p')" = 2B6746PVGB
  if pgrep -f '^/Applications/NizloRemote.app/Contents/MacOS/NizloRemote' >/dev/null; then
    echo 'Quit Nizlo Remote before replacing it.' >&2
    exit 1
  fi
else
  test "${2:-}" != --replace
fi
test ! -L "$destination"
test ! -e "$stage"
test ! -e "$backup"
mkdir -p "$work/mount"
xcrun stapler validate "$input"
hdiutil attach -readonly -nobrowse -quiet -mountpoint "$work/mount" "$input"
mounted=1
app="$work/mount/NizloRemote.app"
test -d "$app"
test ! -L "$app"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")" = com.nizlo.remote.client
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")" = 1.5.0
requirement='anchor apple generic and certificate leaf[subject.OU] = "2B6746PVGB" and identifier "com.nizlo.remote.client"'
codesign --verify --deep --strict -R="$requirement" "$app"
spctl --assess --type execute "$app"
ditto "$app" "$stage"
codesign --verify --deep --strict -R="$requirement" "$stage"
spctl --assess --type execute "$stage"
if [ "${2:-}" = --replace ]; then
  mv "$destination" "$backup"
  replaced=1
fi
mv "$stage" "$destination"
codesign --verify --deep --strict -R="$requirement" "$destination"
spctl --assess --type execute "$destination"
verified=1
if [ "$replaced" -eq 1 ]; then
  echo "Previous app retained at $backup"
fi
echo "Installed $destination alongside stock RustDesk."
