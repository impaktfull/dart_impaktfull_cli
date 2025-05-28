#!/bin/bash

if [ ! -f ~/.zshrc ]; then
    echo "~/.zshrc does not exist, please install zsh and run this script again"
    exit -1
fi

INSTALL_DIR="$HOME/.impaktfull/impaktfull_cli"

echo "Downloading impaktfull_cli"
mkdir -p $INSTALL_DIR
curl -fsSL https://cli.impaktfull.com/download/impaktfull_cli -o $INSTALL_DIR/impaktfull_cli
chmod +x $INSTALL_DIR

EXPORT_VALUE='export PATH="$HOME/.impaktfull/impaktfull_cli:$PATH"'
if ! grep -q "$EXPORT_VALUE" ~/.zshrc; then
    echo "Adding impaktfull_cli to PATH"
    echo "" >> ~/.zshrc
    echo "# Add impaktfull tools to PATH" >> ~/.zshrc
    echo "$EXPORT_VALUE" >> ~/.zshrc
fi

echo "Download impaktfull_cli completed!"
echo ""
echo "Test by running 'impaktfull_cli --help'"
