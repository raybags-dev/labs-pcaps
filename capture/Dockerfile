FROM python:3.11-slim

# install tshark (Wireshark CLI) and required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      tshark tcpdump iproute2 && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user (optional)
RUN useradd -ms /bin/bash netcap
WORKDIR /home/netcap

# Copy project files
COPY requirements.txt /home/netcap/requirements.txt
RUN pip install --no-cache-dir -r /home/netcap/requirements.txt

COPY capture.py /home/netcap/capture.py
COPY processor.py /home/netcap/processor.py
COPY logging.yml /home/netcap/logging.yml

RUN chown -R netcap:netcap /home/netcap
USER netcap

VOLUME ["/pcaps", "/output"]

ENV PCAP_DIR=/pcaps
ENV OUTPUT_DIR=/output
ENV ROTATE_SIZE_MB=50
ENV MAX_FILES=10

CMD ["python", "capture.py"]
