import subprocess
import csv
import sys
from pathlib import Path
import json
from datetime import datetime

def process_pcap(pcap_path, out_json=None, out_csv=None):
    fields = [
        'frame.time_epoch',
        'ip.src', 'ip.dst',
        '_ws.col.Protocol', 'frame.len', '_ws.col.Info'
    ]
    tshark_cmd = [
        "tshark", "-r", str(pcap_path),
        "-T", "fields"
    ]
    for f in fields:
        tshark_cmd += ["-e", f]
    tshark_cmd += ["-E", "separator=|", "-E", "quote=d", "-E", "occurrence=f"]

    proc = subprocess.Popen(tshark_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = proc.communicate()
    if proc.returncode != 0:
        print("tshark error:", err, file=sys.stderr)
        return

    rows = []
    for line in out.splitlines():
        parts = line.split("|")
        # some packets may not have all fields; pad
        parts += [""] * (len(fields) - len(parts))
        ts = parts[0]
        try:
            ts_f = float(ts)
            t = datetime.utcfromtimestamp(ts_f).isoformat() + "Z"
        except:
            t = ""
        row = {
            "time": t,
            "src": parts[1],
            "dst": parts[2],
            "protocol": parts[3],
            "length": parts[4],
            "info": parts[5]
        }
        rows.append(row)

    if out_json:
        Path(out_json).write_text(json.dumps(rows, indent=2))
    if out_csv:
        import csv
        keys = ["time", "src", "dst", "protocol", "length", "info"]
        with open(out_csv, "w", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=keys)
            writer.writeheader()
            for r in rows:
                writer.writerow(r)
    return rows

if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("pcap", help="pcap file to process")
    p.add_argument("--json", help="output json file")
    p.add_argument("--csv", help="output csv file")
    args = p.parse_args()
    process_pcap(args.pcap, args.json, args.csv)
