#!/bin/bash -eu
set -e

VERSION=_VERSION_
VARIANT=_VARIANT_

ARCHITECTURE="$(uname -m)"
if [[ "$ARCHITECTURE" == "x86_64_" ]]; then
  echo
  echo "This script will download and install Thonny ($VARIANT-$VERSION) for Linux (32 or 64-bit PC)."
  read -p "Press ENTER to continue or Ctrl+C to cancel."

  FILENAME=$VARIANT-$VERSION-$ARCHITECTURE.tar.gz
  URL="https://github.com/thonny/thonny/releases/download/v$VERSION/$FILENAME"

  echo "Downloading $URL"

  TMPDIR=$(mktemp -d -p .)
  wget -O $TMPDIR/$FILENAME $URL
  tar -zxf $TMPDIR/$FILENAME -C $TMPDIR
  $TMPDIR/thonny/install
  rm -rf $TMPDIR

  echo
  read -p "Press ENTER to exit the installer."
else
  echo "Thonny only provides pre-built bundles for x86_64 (not $ARCHITECTURE)."
  TARGET=~/apps/thonny
  PYVER="$(python3 -V 2>&1)"
  GOODVER="Python 3\.(7|8|9|10)\.*"
  if [[ "$PYVER" =~ $GOODVER ]]; then
    PYLOC="$(which python3 2>&1)"
    echo "I could install Thonny into a venv under your existing $PYVER ($PYLOC)."
    read -p "Press ENTER to continue or Ctrl+C to cancel."

    # Install non-pip dependencies
    if [[ -f /etc/arch-release ]]; then
      if ! pacman -Qi $package > /dev/null ; then
        echo "Going to install 'tk' first"
        sudo pacman -S tk
      fi
    elif [[ -f /etc/debian-release ]]; then
      echo "Having debian"
    elif [[ -f /etc/gentoo-release ]]; then
      echo "emerge"
    elif [[ -f /etc/redhat-release ]]; then
      echo "rpm"
    elif [[ -f /etc/SuSE-release ]]; then
      echo "zypp"
    else
      echo "Can't determine your package manager, assuming Tkinter and venv are present."
    fi

    if [[ -d $TARGET ]]; then
      echo "Removing existing Thonny installation at $TARGET"
      rm -rf $TARGET
    fi

    echo "Creating virtual environment for Thonny"
    python3 -m venv $TARGET

    echo "Installing Thonny and its dependencies"
    $TARGET/bin/pip3 install thonny

    echo "Creating the launcher"
    LAUNCHER=~/.local/share/applications/Thonny.desktop
    SITE_PACKAGES=$($TARGET/bin/python3 -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')
    echo "[Desktop Entry]" > $LAUNCHER
    echo "Type=Application" >> $LAUNCHER
    echo "Name=Thonny" >> $LAUNCHER
    echo "GenericName=Python IDE" >> $LAUNCHER
    echo "Exec=$TARGET/bin/thonny %F" >> $LAUNCHER
    echo "Comment=Python IDE for beginners" >> $LAUNCHER
    echo "Icon=$SITE_PACKAGES/thonny/res/thonny.png" >> $LAUNCHER
    echo "StartupWMClass=Thonny" >> $LAUNCHER
    echo "Terminal=false" >> $LAUNCHER
    echo "Categories=Development;IDE" >> $LAUNCHER
    echo "Keywords=programming;education" >> $LAUNCHER
    echo "MimeType=text/x-python;" >> $LAUNCHER
    echo "Actions=Edit;" >> $LAUNCHER
    echo "" >> $LAUNCHER
    echo "[Desktop Action Edit]" >> $LAUNCHER
    echo "Exec=$TARGET/bin/thonny %F" >> $LAUNCHER
    echo "Name=Edit with Thonny" >> $LAUNCHER
  else
    echo "Your system doesn't seem to have suitable Python interpreter"
    exit 1
  fi
fi

