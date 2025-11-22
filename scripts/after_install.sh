#!/bin/bash
echo "Running AfterInstall..."

APP_DIR="/var/www/myapp"

# Give full permissions to app directory
sudo chmod -R 755 $APP_DIR

# Change to app directory
cd $APP_DIR || exit 1

# Install Node dependencies
echo "Installing Node dependencies..."
npm install

echo "AfterInstall completed successfully."
