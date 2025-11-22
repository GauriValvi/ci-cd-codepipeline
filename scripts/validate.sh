#!/bin/bash
echo "Validating application..."

# Test if port 80 is responding
curl -f http://localhost:80 > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "App is NOT running — validation failed!"
  exit 1
fi

echo "App is running — validation passed!"
