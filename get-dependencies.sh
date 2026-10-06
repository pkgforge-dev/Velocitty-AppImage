#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
  meson \
  ninja \
  gettext \
  glib2-devel \
  git \
  desktop-file-utils \
  gsettings-desktop-schemas \
  gtk4 \
  libadwaita \
  vte4 \
  python \
  python-gobject \
  python-setproctitle \
  python-xapp \
  xapp-symbolic-icons

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building velocitty from upstream source..."
echo "---------------------------------------------------------------"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
  git clone --depth 1 https://github.com/xapp-project/velocitty.git /tmp/velocitty
  cd /tmp/velocitty
  VERSION=$(git describe --tags --always)
else
  TAG=$(git ls-remote --tags --refs https://github.com/xapp-project/velocitty.git | sed -E 's/^[0-9a-f]+[[:space:]]+refs\/tags\///' | grep -E '^[0-9]+\.[0-9]+' | sort -V | tail -n 1)
  if [ -n "$TAG" ]; then
    git clone --depth 1 --branch "$TAG" https://github.com/xapp-project/velocitty.git /tmp/velocitty
    cd /tmp/velocitty
    VERSION="$TAG"
  else
    git clone --depth 1 https://github.com/xapp-project/velocitty.git /tmp/velocitty
    cd /tmp/velocitty
    VERSION=$(git describe --tags --always)
  fi
fi

echo "$VERSION" >~/version

meson setup build \
  --prefix=/usr \
  --buildtype=plain

ninja -C build
ninja -C build install
glib-compile-schemas /usr/share/glib-2.0/schemas
