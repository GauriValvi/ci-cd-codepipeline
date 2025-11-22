#!/bin/bash
echo "Validating application..."

# Maximum number of retries
MAX_RETRIES=10
# Delay between retries in seconds
SLEEP_TIME=3

for i in $(seq 1 $MAX_RETRIES); do
  echo "Checking if app is running (attempt $i)..."
  curl -f http://localhost:80 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "App is running — validation passed!"
    exit 0
  fi
  sleep $SLEEP_TIME
done

echo "App is NOT running — validation failed after $MAX_RETRIES attempts!"
exit 1
