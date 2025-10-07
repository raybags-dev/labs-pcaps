#!/bin/sh
TARGETS="${TARGETS:-https://raybags.com http://host.docker.internal:8080}"
while true; do
  for t in $TARGETS; do
    curl -sS -o /dev/null "$t" || true
    sleep 0.5
  done
  sleep 1
done
