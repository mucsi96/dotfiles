#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

SUBLIME_DEST=~/.config/sublime-text-3/Packages/User
SUBLIME_BIN_DEST=/usr/bin/subl

if [ ! -e "$SUBLIME_DEST" ]; then
    echo "Installing Sublime config"
    ln -s $DIR/User "$SUBLIME_DEST"
fi

if [ ! -e "$SUBLIME_BIN_DEST" ]; then
    echo "Installing Sublime binary"
    sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "$SUBLIME_BIN_DEST"
fi
