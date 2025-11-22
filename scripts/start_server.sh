#!/bin/bash
echo "Starting Node server..."

cd /var/www/myapp
nohup node server.js > output.log 2>&1 &
