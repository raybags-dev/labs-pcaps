#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

echo "🧪 Starting Full Test Workflow"
echo "================================"
echo ""

# 1. Check initial status
echo "📊 Step 1: Checking service status..."
./scripts/status.sh
echo ""
read -p "Press Enter to continue to logs..."
echo ""

# 2. View logs (only last 20 lines)
echo "📋 Step 2: Viewing recent logs..."
echo "--- Capture Service Logs ---"
docker-compose logs --tail=20 capture
echo ""
echo "--- Generator Service Logs ---"
docker-compose logs --tail=20 generator
echo ""
read -p "Press Enter to generate internal traffic..."
echo ""

# 3. Generate internal traffic
echo "🏠 Step 3: Generating internal traffic..."
./scripts/test-internal.sh
echo ""
read -p "Press Enter to generate external traffic..."
echo ""

# 4. Generate external traffic
echo "🌐 Step 4: Generating external traffic..."
./scripts/test-external.sh
echo ""
echo "⏳ Waiting 10 seconds for packets to be captured..."
sleep 10
echo ""
read -p "Press Enter to check status again..."
echo ""

# 5. Check status again
echo "📊 Step 5: Checking status after traffic generation..."
./scripts/status.sh
echo ""
read -p "Press Enter to process captured packets..."
echo ""

# 6. Process captured packets
echo "📦 Step 6: Processing captured packets..."
./scripts/process-pcaps.sh
echo ""
read -p "Press Enter to view debug information..."
echo ""

# 7. Debug information
echo "🔍 Step 7: Showing debug information..."
./scripts/debug.sh
echo ""

# Final summary
echo "================================"
echo "✅ Full Test Workflow Complete!"
echo "================================"
echo ""
echo "📁 Check results:"
echo "  - PCAP files: ls -lh pcaps/"
echo "  - Output files: ls -lh output/"
echo "  - View JSON: cat output/*.json | head -n 50"
echo "  - View CSV: cat output/*.csv | head -n 20"
echo ""
echo "🔄 To run tests again:"
echo "  ./scripts/full-test.sh"
echo ""
