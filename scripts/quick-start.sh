#!/bin/bash
set -e
echo "⚡ Quick start: building and starting..."
docker-compose build
docker-compose up -d
echo ""
echo "✅ Services are running!"
docker-compose ps
echo ""
echo "💡 Next steps:"
echo "  ./scripts/logs.sh           # View logs"
echo "  ./scripts/status.sh         # Check status"
echo "  ./scripts/test-internal.sh  # Generate traffic"
