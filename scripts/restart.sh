#!/bin/bash
set -e
echo "🔄 Restarting services..."
docker-compose restart
echo "✅ Services restarted!"
docker-compose ps
