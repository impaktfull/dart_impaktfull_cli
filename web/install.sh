#!/bin/bash

if [ ! -f ~/.zshrc ]; then
    echo "~/.zshrc does not exist, please install zsh and run this script again"
    exit -1
fi

INSTALL_DIR="$HOME/.impaktfull/impaktfull_cli"
CLI_PATH="$INSTALL_DIR/impaktfull_cli"

echo "Downloading impaktfull_cli"
mkdir -p $INSTALL_DIR
curl -fsSL https://cli.impaktfull.com/download/impaktfull_cli -o $CLI_PATH
echo "Download impaktfull_cli completed!"
chmod +x $CLI_PATH

EXPORT_IMP_CLI_ZSHRC='export PATH="$HOME/.impaktfull/impaktfull_cli:$PATH"'
touch ~/.impaktfull/impaktfull_cli/.zshrc
if ! grep -q "$EXPORT_IMP_CLI_ZSHRC" ~/.impaktfull/impaktfull_cli/.zshrc; then
    echo "Adding impaktfull_cli to PATH"
    echo "# Add impaktfull tools to PATH" >> ~/.impaktfull/impaktfull_cli/.zshrc
    echo "$EXPORT_IMP_CLI_ZSHRC" >> ~/.impaktfull/impaktfull_cli/.zshrc
fi

EXPORT_IMP_ZSHRC="source ~/.impaktfull/impaktfull_cli/.zshrc"
if ! grep -q "$EXPORT_IMP_ZSHRC" ~/.zshrc; then
    echo "# Add impaktfull-cli zshrc file to zshrc" >> ~/.zshrc
    echo "$EXPORT_IMP_ZSHRC" >> ~/.zshrc
fi

source ~/.zshrc
exec zsh

impaktfull_cli --help

echo ""
echo "Restart your terminal and test by running 'impaktfull_cli --help'"
