#!/bin/bash
echo "🔍 === Debug Information ==="
echo ""
echo "=== Docker Compose Status ==="
docker-compose ps
echo ""
echo "=== Capture Container Logs (last 30 lines) ==="
docker-compose logs --tail=30 capture
echo ""
echo "=== Generator Container Logs (last 30 lines) ==="
docker-compose logs --tail=30 generator
echo ""
echo "=== Network Interfaces in Capture Container ==="
docker-compose exec capture ip addr show
echo ""
echo "=== Environment in Capture Container ==="
docker-compose exec capture env | grep -E "(PCAP|OUTPUT|CAPTURE)" | sort
echo ""
echo "=== Files ==="
echo "PCAP files:"
ls -lh ../pcaps/ 2>/dev/null || echo "  None"
echo ""
echo "Output files:"
ls -lh ../output/ 2>/dev/null || echo "  None"
