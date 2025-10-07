#!/bin/bash
set -e
echo "▶️  Starting services..."
docker-compose up -d
echo "✅ Services started!"
echo ""
docker-compose ps
