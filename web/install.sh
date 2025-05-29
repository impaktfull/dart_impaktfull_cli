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

EXPORT_VALUE='export PATH="$HOME/.impaktfull/impaktfull_cli:$PATH"'
touch ~/.impaktfull/impaktfull_cli/.zshrc
if ! grep -q "$EXPORT_VALUE" ~/.impaktfull/impaktfull_cli/.zshrc; then
    echo "Adding impaktfull_cli to PATH"
    echo "# Add impaktfull tools to PATH" >> ~/.impaktfull/impaktfull_cli/.zshrc
    echo "$EXPORT_VALUE" >> ~/.impaktfull/impaktfull_cli/.zshrc
    echo "# Add impaktfull-cli zshrc file to zshrc" >> ~/.zshrc
    echo "source ~/.impaktfull/impaktfull_cli/.zshrc" >> ~/.zshrc
    source ~/.zshrc
    exec zsh
fi

impaktfull_cli --help

echo ""
echo "Restart your terminal and test by running 'impaktfull_cli --help'"
