#!/bin/bash
#
# Builds the distributable disk image. The app and an /Applications symlink go
# into a read/write image, Finder is scripted to lay the window out, and the
# result is converted to a compressed read-only image.
#
# The layout is the point: Finder stores it in a .DS_Store that travels inside
# the image, so everyone who opens the DMG sees the same window instead of
# their own Finder defaults.
#
# Deliberately no background art. A background image is static, but Finder's
# icon labels turn white in dark mode — a light background with a drawn arrow
# renders them unreadable. Position alone (app left, /Applications right, same
# baseline) conveys the drag, and stays legible in both appearances.
#
# Usage: make-dmg.sh <app name> <path to .app> <output .dmg>
set -euo pipefail

APP_NAME="$1"
BUNDLE="$2"
DMG="$3"

DIST="$(dirname "$DMG")"
STAGE="$DIST/dmg"
RW_DMG="$DIST/rw.dmg"

cleanup() { rm -rf "$STAGE" "$RW_DMG"; }
trap cleanup EXIT

rm -rf "$STAGE" "$DMG" "$RW_DMG"
mkdir -p "$STAGE"
ditto "$BUNDLE" "$STAGE/$APP_NAME.app"
ln -s /Applications "$STAGE/Applications"

# Room for Finder to write the .DS_Store; the slack costs nothing once the
# image is compressed down to UDZO at the end. HFS+ because a DMG laid out for
# Finder is the one case where it's still the safer filesystem.
size_kb=$(($(du -sk "$STAGE" | cut -f1) + 20000))
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE" -ov \
	-fs HFS+ -format UDRW -size "${size_kb}k" "$RW_DMG" >/dev/null
rm -rf "$STAGE"

# Mounted browsable on purpose: Finder has to see the volume to script it.
# The mount point is read back rather than assumed, because a stale
# /Volumes/<name> would push this one to "<name> 1" and the AppleScript below
# would then address the wrong disk.
mount_point=$(hdiutil attach "$RW_DMG" -readwrite -noverify |
	awk -F'\t' '/\/Volumes\//{print $NF}' | tail -1)
volume_name=$(basename "$mount_point")

# First run prompts for Automation consent for whatever launched this script.
osascript <<EOF
tell application "Finder"
	tell disk "$volume_name"
		open
		set current view of container window to icon view
		set toolbar visible of container window to false
		set statusbar visible of container window to false
		-- 600x400 content area; the two icons sit 150 pt from either edge and
		-- slightly above centre, so the labels below them don't make the pair
		-- look bottom-heavy.
		set the bounds of container window to {200, 120, 800, 520}
		set opts to the icon view options of container window
		set arrangement of opts to not arranged
		set icon size of opts to 128
		set text size of opts to 12
		set position of item "$APP_NAME.app" of container window to {150, 175}
		set position of item "Applications" of container window to {450, 175}
		update without registering applications
		close
	end tell
end tell
EOF

# Finder writes the .DS_Store lazily; flush before pulling the volume away.
sync
sleep 2
hdiutil detach "$mount_point" >/dev/null ||
	{ sleep 3; hdiutil detach "$mount_point" -force >/dev/null; }

hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG" >/dev/null
