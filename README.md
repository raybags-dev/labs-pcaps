# labs-pcap

A Python/Docker project to capture live network traffic into rotating pcap files, process them to extract metadata, and demonstrate network analysis pipelines.

    - packet analysis | network security | containerized.

## 🎯 Features

- **Live Traffic Capture**: Real-time packet capture using tshark
- **Automatic Rotation**: Pcap files rotate automatically by size (configurable)
- **Metadata Extraction**: Generate JSON metadata for each capture session
- **Traffic Processing**: Convert pcap files to JSON/CSV for analysis
- **Containerized**: Fully dockerized capture and traffic generation services
- **Multiple Traffic Sources**: Captures both internal container traffic and external requests

## 📋 Prerequisites

Before you begin | ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: Usually comes with Docker Desktop
- **Git**: [Install Git](https://git-scm.com/downloads)

Verify installations:
```bash
docker --version
docker-compose --version
git --version
```

## Quick Start (For Cloned Repository)

### 1. Clone the Repository
```bash
git clone git@github.com:raybags-dev/labs-pcaps.git
cd labs-pcap
```

### 2. Run the Preparation Script
This sets up all necessary directories, permissions, and helper scripts:
```bash
chmod +x prep.sh
./prep.sh
```

The prep script will:
- Create `pcaps/` and `output/` directories
- Set proper permissions (777) for volume mounts
- Generate all helper scripts in `scripts/` directory
- Make all scripts executable

### 3. Build and Start Services
```bash
./scripts/quick-start.sh
```

This will:
- Build all Docker images
- Start all services (capture, generator, demo-http)
- Display running services status

### 4. Verify Everything is Working
```bash
# Check service status and captured files
./scripts/status.sh

# View live logs
./scripts/logs.sh

# Or view logs for specific service
./scripts/logs.sh capture
./scripts/logs.sh generator
```

### 5. Generate Traffic
```bash
# Generate internal traffic (between containers)
./scripts/test-internal.sh

# Generate external traffic (to raybags.com)
./scripts/test-external.sh
```

### 6. Process Captured Packets
After some traffic has been captured:
```bash
./scripts/process-pcaps.sh
```

This converts `.pcap` files to `.json` and `.csv` formats in the `output/` directory.

### 7. View Results
```bash
# Check captured pcap files
ls -lh pcaps/

# Check processed output
ls -lh output/

# View a JSON output (example)
cat output/capture-20241007T082030Z.json | head -n 50
```

## 📁 Project Structure

```
labs-pcap/
├── capture/                    # Capture service
│   ├── Dockerfile             # Container definition
│   ├── capture.py             # Main capture logic
│   ├── processor.py           # Pcap processing script
│   ├── requirements.txt       # Python dependencies
│   └── logging.yml            # Logging configuration
├── generator/                 # Traffic generator service
│   ├── Dockerfile
│   └── generator.sh           # Traffic generation script
├── scripts/                   # Helper scripts (created by prep.sh)
│   ├── quick-start.sh        # Build and start everything
│   ├── build.sh              # Build images
│   ├── start.sh              # Start services
│   ├── stop.sh               # Stop services
│   ├── restart.sh            # Restart services
│   ├── logs.sh               # View logs
│   ├── status.sh             # Check status
│   ├── test-internal.sh      # Generate internal traffic
│   ├── test-external.sh      # Generate external traffic
│   ├── process-pcaps.sh      # Process captured files
│   ├── debug.sh              # Debug information
│   ├── reset.sh              # Full reset
│   └── clean.sh              # Clean up
├── pcaps/                     # Captured pcap files (created)
├── output/                    # Processed JSON/CSV files (created)
├── docker-compose.yml         # Service orchestration
├── prep.sh                    # Initial setup script
└── README.md                  # This file
```

## 🛠️ Available Scripts

After running `prep.sh`, you have access to these helper scripts:

| Script | Description |
|--------|-------------|
| `./scripts/quick-start.sh` | Build and start all services (recommended for first run) |
| `./scripts/build.sh` | Build Docker images |
| `./scripts/start.sh` | Start services |
| `./scripts/stop.sh` | Stop all services |
| `./scripts/restart.sh` | Restart all services |
| `./scripts/logs.sh [service]` | View logs (optionally for specific service) |
| `./scripts/status.sh` | Show service status and file counts |
| `./scripts/test-internal.sh` | Generate traffic between containers |
| `./scripts/test-external.sh` | Generate traffic to external site |
| `./scripts/process-pcaps.sh` | Convert pcap files to JSON/CSV |
| `./scripts/debug.sh` | Show detailed debug information |
| `./scripts/reset.sh` | Full reset: stop, clean, rebuild, restart |
| `./scripts/clean.sh` | Stop services and delete all captured files |

## 🔧 Configuration

### Environment Variables

You can modify these in `docker-compose.yml`:

**Capture Service:**
- `PCAP_DIR`: Directory for pcap files (default: `/pcaps`)
- `OUTPUT_DIR`: Directory for metadata (default: `/output`)
- `ROTATE_SIZE_MB`: Rotate pcap when it reaches this size (default: `10`)
- `MAX_FILES`: Maximum number of pcap files to keep (default: `20`)
- `CAPTURE_IFACE`: Network interface to capture (default: `eth0`)

**Generator Service:**
- `TARGETS`: Space-separated list of URLs to request (default: `https://raybags.com http://demo-http:5678`)

### Modifying Rotation Settings

Edit `docker-compose.yml`:
```yaml
environment:
  - ROTATE_SIZE_MB=50  # Rotate at 50MB instead of 10MB
  - MAX_FILES=5        # Keep only 5 files instead of 20
```

Then restart:
```bash
./scripts/restart.sh
```

## 📊 Understanding the Output

### PCAP Files (`pcaps/`)
Raw packet capture files in pcap format:
```
capture-20241007T082030Z.pcap
capture-20241007T083045Z.pcap
```

### Metadata Files (`output/`)
JSON metadata for each capture session:
```json
{
  "pcap": "capture-20241007T082030Z.pcap",
  "start": "2024-10-07T08:20:30Z",
  "end": "2024-10-07T08:30:45Z",
  "size_bytes": 10485760
}
```

### Processed Files (`output/`)
After running `./scripts/process-pcaps.sh`:
- **JSON**: Structured packet data
- **CSV**: Spreadsheet-friendly format with columns: time, src, dst, protocol, length, info

## 🐛 Troubleshooting

### No packets being captured?

1. Check if services are running:
   ```bash
   ./scripts/status.sh
   ```

2. View capture logs:
   ```bash
   ./scripts/logs.sh capture
   ```

3. Generate test traffic:
   ```bash
   ./scripts/test-internal.sh
   ```

4. Check debug info:
   ```bash
   ./scripts/debug.sh
   ```

### Permission errors?

Run the prep script again:
```bash
./prep.sh
```

Or manually fix permissions:
```bash
chmod 777 pcaps output
```

### Container won't start?

View detailed logs:
```bash
docker-compose logs capture
```

Rebuild from scratch:
```bash
./scripts/reset.sh
```

### Port conflicts?

If port 8080 is already in use, edit `docker-compose.yml` and change:
```yaml
ports:
  - "8081:5678"  # Changed from 8080
```

## 🧪 Testing the Setup

### Basic Test Flow

1. Start services:
   ```bash
   ./scripts/quick-start.sh
   ```

2. Generate traffic:
   ```bash
   ./scripts/test-internal.sh
   ```

3. Wait 30 seconds for capture

4. Check for pcap files:
   ```bash
   ls -lh pcaps/
   ```

5. Process the captures:
   ```bash
   ./scripts/process-pcaps.sh
   ```

6. View results:
   ```bash
   ls -lh output/
   cat output/*.json | head -n 20
   ```

## 📚 Learning Resources

### Understanding the Components

- **tshark**: Command-line packet analyzer (Wireshark CLI)
- **pcap**: Packet Capture format - industry standard
- **Docker Bridge Network**: Allows containers to communicate
- **Traffic Generation**: Simulates real network activity

### What Gets Captured?

- HTTP requests between containers
- DNS queries
- TCP handshakes and teardowns
- Protocol headers (IP, TCP, UDP)

**Note**: HTTPS traffic to external sites (like raybags.com) will be encrypted - you'll see the connection but not the content.

## 🤝 Contributing

Feel free to fork this project and customize it for your needs:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🎓 Portfolio Use

This project demonstrates:
- Container orchestration with Docker Compose
- Network traffic analysis
- Python automation
- Shell scripting
- Real-time data capture and processing
- System design for monitoring applications

Perfect for showcasing in:
- Cybersecurity portfolios
- DevOps/SRE portfolios
- Network engineering projects
- Python automation projects

## 📧 Contact

Created by [Your Name] - [Your Email/LinkedIn]

Project Link: [Your Repository URL]

---

**Happy Packet Hunting! 🕵️‍♂️📦**