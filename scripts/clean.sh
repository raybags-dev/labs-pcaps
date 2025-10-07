#!/bin/bash
echo "🧹 Cleaning up..."
docker-compose down -v
rm -rf ../pcaps/* ../output/*
echo "✅ Cleanup complete!"
