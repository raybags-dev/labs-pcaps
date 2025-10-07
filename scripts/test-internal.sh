#!/bin/bash
echo "🏠 Sending test requests to internal demo server..."
docker-compose exec -T generator sh -c '
  for i in $(seq 1 10); do
    echo "  Request $i"
    curl -sS http://demo-http:5678
    sleep 1
  done
'
echo "✅ Internal test complete!"
