FROM python:3.11-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      tshark tcpdump iproute2 && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash netcap
WORKDIR /home/netcap

COPY capture/ ./capture/

RUN pip install --no-cache-dir -r capture/requirements.txt

VOLUME ["/pcaps", "/output"]

ENV PCAP_DIR=/pcaps \
    OUTPUT_DIR=/output \
    CAPTURE_IFACE=any \
    ROTATE_SIZE_MB=50 \
    MAX_FILES=10

USER netcap

WORKDIR /home/netcap/capture

CMD ["python", "capture.py"]
