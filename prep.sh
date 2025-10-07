#!/bin/bash
# prep.sh - Prepare the net-capture project
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Preparing net-capture project..."
echo ""

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p pcaps output scripts

# Set directory permissions
echo "🔐 Setting permissions..."
sudo chmod 777 pcaps output

# Create scripts directory setup script
cat > scripts/setup.sh << 'SETUP_EOF'
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Setting up test scripts..."

# Build script
cat > "$SCRIPT_DIR/build.sh" << 'EOF'
#!/bin/bash
set -e
echo "🏗️  Building Docker images..."
docker-compose build --no-cache
echo "✅ Build complete!"
EOF

# Start script
cat > "$SCRIPT_DIR/start.sh" << 'EOF'
#!/bin/bash
set -e
echo "▶️  Starting services..."
docker-compose up -d
echo "✅ Services started!"
echo ""
docker-compose ps
EOF

# Stop script
cat > "$SCRIPT_DIR/stop.sh" << 'EOF'
#!/bin/bash
echo "⏹️  Stopping services..."
docker-compose down
echo "✅ Services stopped!"
EOF

# Logs script
cat > "$SCRIPT_DIR/logs.sh" << 'EOF'
#!/bin/bash
SERVICE=${1:-}
if [ -z "$SERVICE" ]; then
  docker-compose logs -f
else
  docker-compose logs -f "$SERVICE"
fi
EOF

# Status script
cat > "$SCRIPT_DIR/status.sh" << 'EOF'
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
EOF

# Clean script
cat > "$SCRIPT_DIR/clean.sh" << 'EOF'
#!/bin/bash
echo "🧹 Cleaning up..."
docker-compose down -v
rm -rf ../pcaps/* ../output/*
echo "✅ Cleanup complete!"
EOF

# Restart script
cat > "$SCRIPT_DIR/restart.sh" << 'EOF'
#!/bin/bash
set -e
echo "🔄 Restarting services..."
docker-compose restart
echo "✅ Services restarted!"
docker-compose ps
EOF

# Reset script
cat > "$SCRIPT_DIR/reset.sh" << 'EOF'
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
EOF

# Process pcaps script
cat > "$SCRIPT_DIR/process-pcaps.sh" << 'EOF'
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
EOF

# Test external traffic
cat > "$SCRIPT_DIR/test-external.sh" << 'EOF'
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
EOF

# Test internal traffic
cat > "$SCRIPT_DIR/test-internal.sh" << 'EOF'
#!/bin/bash
echo "🏠 Sending test requests to internal demo server..."
docker-compose exec -T generator sh -c '
  for i in $(seq 1 10); do
    echo "  Request $i"
    curl -sS http://demo-http:5678
    sleep 1
  done
'
echo "✅ Internal test complete!"
EOF

# Quick start
cat > "$SCRIPT_DIR/quick-start.sh" << 'EOF'
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
EOF

# Debug script
cat > "$SCRIPT_DIR/debug.sh" << 'EOF'
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
EOF

# Full test workflow script
cat > "$SCRIPT_DIR/full-test.sh" << 'EOF'
#!/bin/bash
# full-test.sh - Complete test workflow
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
echo "📁 Check your results:"
echo "  - PCAP files: ls -lh pcaps/"
echo "  - Output files: ls -lh output/"
echo "  - View JSON: cat output/*.json | head -n 50"
echo "  - View CSV: cat output/*.csv | head -n 20"
echo ""
echo "🔄 To run tests again:"
echo "  ./scripts/full-test.sh"
echo ""
EOF

# Set permissions
sudo chmod +x "$SCRIPT_DIR"/*.sh

echo "✅ All scripts created and made executable!"
SETUP_EOF

# Make setup script executable and run it
sudo chmod +x scripts/setup.sh
./scripts/setup.sh

echo ""
echo "✅ Project prepared successfully!"
echo ""
echo "📋 Available commands:"
echo "  ./scripts/quick-start.sh    # Build and start everything"
echo "  ./scripts/build.sh          # Build images"
echo "  ./scripts/start.sh          # Start services"
echo "  ./scripts/stop.sh           # Stop services"
echo "  ./scripts/logs.sh [service] # View logs"
echo "  ./scripts/status.sh         # Check status and files"
echo "  ./scripts/test-internal.sh  # Generate internal traffic"
echo "  ./scripts/test-external.sh  # Test external site"
echo "  ./scripts/process-pcaps.sh  # Process captured pcaps"
echo "  ./scripts/debug.sh          # Debug information"
echo "  ./scripts/restart.sh        # Restart services"
echo "  ./scripts/reset.sh          # Full reset"
echo "  ./scripts/clean.sh          # Clean up everything"
echo ""
echo "🚀 Get started with: ./scripts/quick-start.sh"
echo ""