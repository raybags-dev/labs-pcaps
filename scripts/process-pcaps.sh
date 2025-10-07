#!/bin/bash
PCAP_DIR="../pcaps"
OUTPUT_DIR="../output"

echo "📊 Processing pcap files..."
for pcap in "$PCAP_DIR"/*.pcap; do
  if [ -f "$pcap" ]; then
    basename=$(basename "$pcap" .pcap)
    echo "  Processing $basename..."
    docker-compose exec -T capture python /app/processor.py \
      "/pcaps/$basename.pcap" \
      --json "/output/$basename.json" \
      --csv "/output/$basename.csv"
  fi
done
echo "✅ Processing complete! Check output/ directory"
