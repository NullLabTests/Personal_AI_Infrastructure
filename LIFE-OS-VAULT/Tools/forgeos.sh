#!/bin/bash
# ForgeOS — Life OS Service Manager
# Usage: ./forgeos.sh [command]
set -e

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OLLAMA_PORT=${OLLAMA_PORT:-11434}
WEBUI_PORT=${WEBUI_PORT:-8080}
OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0}"

export OLLAMA_HOST="$OLLAMA_HOST"

status()   { echo "  ✓ $1"; }
info()     { echo "  ℹ $1"; }
warn()     { echo "  ⚠ $1"; }

cmd_status() {
  echo "=== ForgeOS Status ==="
  if ollama ps 2>/dev/null | grep -q "."; then
    status "Ollama running (PID: $(pgrep -f 'ollama serve' | head -1))"
    ollama ps 2>/dev/null | awk 'NR>1 {print "    Model: " $1 " (" $3 ")"}'
  else
    warn "Ollama not running"
  fi
  if curl -s --max-time 2 http://localhost:$WEBUI_PORT/ollama-webui.html >/dev/null 2>&1; then
    local CODESPACE_URL="https://${CODESPACE_NAME}-${WEBUI_PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-preview.app.github.dev}"
    status "ForgeOS server running:"
    info "  Local:  http://localhost:$WEBUI_PORT"
    info "  Public: $CODESPACE_URL"
  else
    warn "ForgeOS server not running"
  fi
  if [ -f "$VAULT_DIR/.rag-index.json" ]; then
    local count=$(python3 -c "import json; d=json.load(open('$VAULT_DIR/.rag-index.json')); print(d.get('chunk_count','?'))" 2>/dev/null)
    status "RAG index active ($count chunks)"
  else
    warn "No RAG index — run 'forgeos index'"
  fi
  local commit=$(cd "$VAULT_DIR" && git log --oneline -1 2>/dev/null || echo "N/A")
  info "Last commit: $commit"
}

cmd_start() {
  echo "=== Starting ForgeOS Services ==="
  # Kill any existing instances
  pkill -f "ollama serve" 2>/dev/null || true
  pkill -f "http.server $WEBUI_PORT" 2>/dev/null || true
  sleep 1

  # Start Ollama on 0.0.0.0
  nohup ollama serve > /tmp/ollama.log 2>&1 &
  local OPID=$!
  sleep 3
  if kill -0 $OPID 2>/dev/null; then
    status "Ollama started (PID: $OPID) on 0.0.0.0:$OLLAMA_PORT"
  else
    warn "Ollama failed to start — check /tmp/ollama.log"
  fi

  # Start unified server (web UI + API proxy) on 0.0.0.0
  nohup python3 "$VAULT_DIR/Tools/server.py" $WEBUI_PORT > /tmp/forgeos-server.log 2>&1 &
  local WPID=$!
  sleep 2
  if kill -0 $WPID 2>/dev/null; then
    status "Unified server started (PID: $WPID) on 0.0.0.0:$WEBUI_PORT"
  else
    warn "Server failed — check /tmp/forgeos-server.log"
  fi

  echo ""
  cmd_status
  echo ""
  info "Access web UI at: http://localhost:$WEBUI_PORT/ollama-webui.html"
  info "Codespace URL:   https://${CODESPACE_NAME}-${WEBUI_PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-preview.app.github.dev}"
}

cmd_stop() {
  echo "=== Stopping ForgeOS Services ==="
  pkill -f "server.py $WEBUI_PORT" 2>/dev/null && status "Web server stopped" || warn "Web server not running"
  pkill -f "ollama serve" 2>/dev/null && status "Ollama stopped" || warn "Ollama not running"
}

cmd_restart() { cmd_stop; sleep 1; cmd_start; }

cmd_index() {
  echo "=== Indexing Vault ==="
  python3 "$VAULT_DIR/Tools/life-os-rag.py" index
}

cmd_ask() {
  shift 2>/dev/null
  if [ $# -eq 0 ]; then
    python3 "$VAULT_DIR/Tools/life-os-ask.py" --chat
  else
    python3 "$VAULT_DIR/Tools/life-os-rag.py" ask "$*"
  fi
}

cmd_query() {
  shift 2>/dev/null
  python3 "$VAULT_DIR/Tools/life-os-rag.py" query "$*"
}

cmd_report() {
  local DATE=${1:-$(date +%Y-%m-%d)}
  local FILE="$VAULT_DIR/01_Cognition/Daily-Systems-Report-$DATE.md"
  if [ -f "$FILE" ]; then
    warn "Report $DATE already exists"
    cat "$FILE"
  else
    export FORGEOS_DATE="$DATE" FORGEOS_OUTPUT="$FILE"
    python3 -c "
import os
d = os.environ['FORGEOS_DATE']
y = d[:4]
t = f'''---
tags: [daily-report, cognition, {y}]
date: {d}
---

# Daily Systems Report — {d}

## Wins
-

## Blockers
-

## Next Actions
- [ ]

## Body Notes
-

## Capital Notes
-

## Impact Notes
-
'''
with open(os.environ['FORGEOS_OUTPUT'], 'w') as f:
    f.write(t)
" 2>/dev/null
    status "Created $FILE"
  fi
}

cmd_logs() {
  echo "=== Ollama Logs ==="
  tail -30 /tmp/ollama.log 2>/dev/null || warn "No ollama log"
  echo ""
  echo "=== Server Logs ==="
  tail -10 /tmp/forgeos-server.log 2>/dev/null || warn "No server log"
}

case "${1:-help}" in
  start|up)      cmd_start ;;
  stop|down)     cmd_stop ;;
  restart)       cmd_restart ;;
  status|ps)     cmd_status ;;
  index)         cmd_index ;;
  ask|chat)      cmd_ask "$@" ;;
  query|search)  cmd_query "$@" ;;
  report|today)  cmd_report "$2" ;;
  logs)          cmd_logs ;;
  *)
    echo "ForgeOS — Life OS Service Manager"
    echo ""
    echo "Usage: ./forgeos.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  start       Start Ollama + Web UI (binds 0.0.0.0)"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  status      Show service status"
    echo "  index       Build/refresh RAG index"
    echo "  ask <q>     Ask DeepSeek with vault context"
    echo "  query <q>   Semantic search vault"
    echo "  chat        Interactive chat mode"
    echo "  report      Create today's daily report"
    echo "  logs        Show service logs"
    ;;
esac
