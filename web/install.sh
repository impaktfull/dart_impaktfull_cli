#!/bin/bash

echo "Downloading impaktfull_cli"
curl -fsSL https://cli.impaktfull.com/download/impaktfull_cli -o ~/.impaktfull/impaktfull_cli

echo "Making impaktfull_cli executable"
chmod +x ~/.impaktfull/impaktfull_cli/impaktfull_cli

echo "Adding impaktfull_cli to PATH"
echo 'export PATH="$HOME/.impaktfull/impaktfull_cli/impaktfull_cli:$PATH"' >> ~/.zshrc

echo "Done"
