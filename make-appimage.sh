#!/bin/sh
set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=/usr/share/applications/org.x.velocitty.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/velocitty.svg
export DEPLOY_PYTHON=1
export APPNAME=Velocitty

export PATH_MAPPING='
	/usr/share/velocitty:${SHARUN_DIR}/share/velocitty
'

# Deploy dependencies
quick-sharun \
  /usr/bin/velocitty \
  /usr/share/velocitty \
  /usr/lib/libgtk-4.so* \
  /usr/lib/libadwaita-1.so* \
  /usr/lib/libvte-2.91-gtk4.so* \
  /usr/lib/libxapp.so*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the AppImage
quick-sharun --simple-test ./dist/*.AppImage
