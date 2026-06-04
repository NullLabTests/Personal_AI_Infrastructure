#!/usr/bin/env bash
# ask-vault.sh — Query your ForgeOS vault using Ollama + nomic-embed-text RAG
set -euo pipefail

OLLAMA="${OLLAMA_URL:-http://localhost:11434}"
MODEL="${OLLAMA_MODEL:-deepseek-r1:1.5b}"
EMBED_MODEL="nomic-embed-text"

# If only one argument, treat it as the query (use default vault)
if [ $# -eq 1 ]; then
  QUERY="$1"
  VAULT="$(cd "$(dirname "$0")/../LIFE-OS-VAULT" && pwd)"
elif [ $# -ge 2 ]; then
  VAULT="$1"
  QUERY="$2"
else
  echo "Usage: ./ask-vault.sh <vault-path> \"your question\""
  echo "   or: ./ask-vault.sh \"your question\" (uses default vault path)"
  echo ""
  echo "Examples:"
  echo "  ./ask-vault.sh \"What were my wins this week?\""
  echo "  ./ask-vault.sh \"Summarize my recent health data\""
  exit 1
fi

# Resolve relative path
VAULT="$(cd "$VAULT" 2>/dev/null && pwd || echo "$VAULT")"

echo "🧠 ForgeOS Vault Query"
echo "   Vault: $VAULT"
echo "   Model: $MODEL"
echo "   Question: $QUERY"
echo ""

# Check Ollama
if ! curl -s "$OLLAMA/api/tags" &>/dev/null; then
  echo "❌ Ollama not running at $OLLAMA"
  echo "   Start it: ollama serve"
  exit 1
fi

# Gather vault content
echo "📖 Reading vault files..."
FILES=$(find "$VAULT" -name '*.md' -not -path '*/.git/*' | head -5)
CONTENT=""

if [ -z "$FILES" ]; then
  echo "⚠️  No markdown files found in vault"
  exit 1
fi

while IFS= read -r f; do
  REL="${f#$VAULT/}"
  TEXT=$(head -50 "$f" | sed -n '/^```/q; /^---$/,/^---$/d; p' | head -30)
  if [ -n "$TEXT" ]; then
    CONTENT="$CONTENT
=== $REL ===
$TEXT"
  fi
done <<< "$FILES"

CHAR_COUNT=${#CONTENT}
echo "   Loaded $(echo "$FILES" | wc -l) files, ${CHAR_COUNT} characters"
echo ""

# Build prompt
PROMPT="You are analyzing the ForgeOS Life OS vault. Below is the content of recent notes.

$CONTENT

Answer the following question based ONLY on the vault content above. If the vault doesn't contain the answer, say so clearly.

Question: $QUERY"

echo "🤖 Asking $MODEL (this may take 30-60s)..."
echo ""

# Non-streaming for reliability
RESPONSE=$(curl -s --max-time 120 "$OLLAMA/api/generate" -d "{
  \"model\": \"$MODEL\",
  \"prompt\": $(echo "$PROMPT" | jq -Rs '.'),
  \"stream\": false,
  \"options\": {
    \"num_ctx\": 8192,
    \"temperature\": 0.3
  }
}" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin.read())
  print(d.get('response', '(empty response)'))
except Exception as e:
  print(f'(error: {e})')
")

echo "$RESPONSE"

echo ""
echo ""
echo "✅ Done"
