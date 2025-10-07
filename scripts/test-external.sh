#!/bin/bash
echo "🌐 Sending test requests to raybags.com..."
docker-compose exec -T generator sh -c '
  for i in $(seq 1 5); do
    echo "  Request $i"
    curl -sS -o /dev/null -w "Status: %{http_code}\n" https://raybags.com
    sleep 2
  done
'
echo "✅ External test complete!"
