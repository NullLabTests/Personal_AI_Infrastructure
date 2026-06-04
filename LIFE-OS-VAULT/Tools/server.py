#!/usr/bin/env python3
"""
ForgeOS unified server — serves web UI + proxies Ollama API on same port.
Usage: python3 server.py [port]
This single port serves both the web UI and proxies /api/* to Ollama.
In Codespace, forward this port — the web UI works without CORS issues.
"""

import os, sys, json, re, urllib.request, http.server, socketserver

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
OLLAMA_BASE = "http://localhost:11434"
VAULT_TOOLS = os.path.join(os.path.dirname(os.path.abspath(__file__)))

HTML_PATH = os.path.join(VAULT_TOOLS, "ollama-webui.html")

class ForgeOSHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=VAULT_TOOLS, **kwargs)

    def do_PROXY(self, method, path):
        target = f"{OLLAMA_BASE}{path}"
        body = None
        length = int(self.headers.get("Content-Length", 0))
        if length > 0:
            body = self.rfile.read(length)
        req = urllib.request.Request(target, data=body, method=method,
            headers={"Content-Type": "application/json"})
        try:
            resp = urllib.request.urlopen(req, timeout=300)
            data = resp.read()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(data)
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(e.read())
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())

    def do_GET(self):
        if self.path.startswith("/api/"):
            return self.do_PROXY("GET", self.path)
        return super().do_GET()

    def do_POST(self):
        if self.path.startswith("/api/"):
            return self.do_PROXY("POST", self.path)
        return super().do_POST()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def log_message(self, format, *args):
        sys.stderr.write(f"[ForgeOS] {args[0]} {args[1]} {args[2]}\n")

if __name__ == "__main__":
    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("0.0.0.0", PORT), ForgeOSHandler)
    print(f"ForgeOS server running on http://0.0.0.0:{PORT}")
    print(f"  Web UI:     http://0.0.0.0:{PORT}/ollama-webui.html")
    print(f"  API proxy:  http://0.0.0.0:{PORT}/api/ → {OLLAMA_BASE}")
    print(f"  Serving:    {VAULT_TOOLS}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        httpd.shutdown()
