#!/bin/bash
set -e
echo "♻️  Full reset: stopping, cleaning, rebuilding..."
docker-compose down -v
rm -rf ../pcaps/* ../output/*
docker-compose build --no-cache
docker-compose up -d
echo ""
echo "✅ Reset complete! Services are running."
docker-compose ps
