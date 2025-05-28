#!/bin/bash

if [ ! -f ~/.zshrc ]; then
    echo "~/.zshrc does not exist, please install zsh and run this script again"
    exit -1
fi

INSTALL_DIR="$HOME/.impaktfull/impaktfull_cli"

echo "Downloading impaktfull_cli"
mkdir -p $INSTALL_DIR
curl -fsSL https://cli.impaktfull.com/download/impaktfull_cli -o $INSTALL_DIR/impaktfull_cli

echo "Making impaktfull_cli executable"
chmod +x $INSTALL_DIR

echo "Adding impaktfull_cli to PATH"
EXPORT_VALUE="export PATH=\"$INSTALL_DIR:\$PATH\""
if ! grep -q "$EXPORT_VALUE" ~/.zshrc; then
    echo "$EXPORT_VALUE" >> ~/.zshrc
fi

echo "Done"
