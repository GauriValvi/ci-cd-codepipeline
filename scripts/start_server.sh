#!/bin/bash
echo "Starting Node server..."

cd /path/to/app

# Ensure dependencies are installed
npm install

# Start the app in the background so the script doesn’t block
nohup npm start > app.log 2>&1 &
