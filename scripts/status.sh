#!/bin/bash
echo "=== Service Status ==="
docker-compose ps
echo ""
echo "=== Captured Files ==="
echo "PCAP files:"
ls -lh ../pcaps/ 2>/dev/null || echo "  No pcap files yet"
echo ""
echo "Output files:"
ls -lh ../output/ 2>/dev/null || echo "  No output files yet"
