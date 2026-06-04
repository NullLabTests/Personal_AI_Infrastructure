#!/bin/bash
# Life OS CLI Assistant — ask DeepSeek anything about your vault
# Usage: ./life-os-ask.sh "your question" [model]
#        ./life-os-ask.sh --chat   (interactive mode)

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
exec python3 "$VAULT_DIR/Tools/life-os-ask.py" "$@"
