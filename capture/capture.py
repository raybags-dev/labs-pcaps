import os
import subprocess
import logging
from datetime import datetime
import signal
import sys

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

iface = os.getenv("CAPTURE_IFACE", "any")
pcap_dir = os.getenv("PCAP_DIR", "/app/pcaps")
output_dir = os.getenv("OUTPUT_DIR", "/app/output")

os.makedirs(pcap_dir, exist_ok=True)
os.makedirs(output_dir, exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
pcap_path = os.path.join(pcap_dir, f"capture_{timestamp}.pcap")

logging.info("Capture service starting")
logging.info(f"Interface: {iface}")
logging.info(f"Saving PCAP to: {pcap_path}")

def shutdown(signum, frame):
    logging.info(f"Received signal {signum}, exiting...")
    try:
        process.terminate()
    except Exception:
        pass
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown)
signal.signal(signal.SIGINT, shutdown)

try:
    process = subprocess.Popen(
        ["tshark", "-i", iface, "-w", pcap_path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    logging.info("Tshark capture started successfully")

    # Continuously read stderr to detect errors
    while True:
        err = process.stderr.readline()
        if err:
            logging.error(f"Tshark error: {err.decode().strip()}")
        if process.poll() is not None:
            logging.warning("Tshark process exited, container will restart")
            break

except Exception as e:
    logging.error(f"Failed to start capture: {e}")
