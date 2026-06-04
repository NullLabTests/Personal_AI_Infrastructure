#!/usr/bin/env bash
# setup.sh — One-shot ForgeOS bootstrap installer
set -euo pipefail

FORGEOS_DIR="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; fail_count=$((fail_count+1)); }

echo -e "${CYAN}${BOLD}"
echo "  ╔═══════════════════════════════════════════╗"
echo "  ║        ForgeOS — Bootstrap Installer      ║"
echo "  ║  Fully Local · Systems-Thinking · Life OS  ║"
echo "  ╚═══════════════════════════════════════════╝"
echo -e "${NC}"

fail_count=0

# ── Step 1: Ollama ──
echo -e "${BOLD}[1/5] Ollama${NC}"
if command -v ollama &>/dev/null; then
  ok "Ollama already installed"
else
  echo "  Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
  ok "Ollama installed"
fi

# ── Step 2: Pull models ──
echo -e "${BOLD}[2/5] LLM Models${NC}"
if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
  echo "  Starting Ollama..."
  ollama serve &>/tmp/ollama-setup.log &
  sleep 4
fi

for model in deepseek-r1:1.5b nomic-embed-text; do
  if ollama list 2>/dev/null | grep -q "$model"; then
    ok "$model already pulled"
  else
    echo "  Pulling $model (this may take a few minutes)..."
    ollama pull "$model"
    ok "$model pulled"
  fi
done

ok "deepseek-r1:7b available (optional: ollama pull deepseek-r1:7b)"

# ── Step 3: Bun + Pulse ──
echo -e "${BOLD}[3/5] PAI Pulse Dashboard${NC}"
if command -v bun &>/dev/null || test -f "$HOME/.bun/bin/bun"; then
  ok "Bun already installed"
else
  echo "  Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
  ok "Bun installed"
fi

if [ -f ~/.claude/PAI/PULSE/pulse.ts ]; then
  ok "Pulse already configured"
else
  echo "  Configuring Pulse..."
  mkdir -p ~/.claude/PAI/PULSE
  cp -r "$FORGEOS_DIR/Releases/v5.0.0/.claude/PAI/PULSE/"* ~/.claude/PAI/PULSE/
  cd ~/.claude/PAI/PULSE/Observability && bun install &>/dev/null
  ok "Pulse configured"
fi

# ── Step 4: Git remote ──
echo -e "${BOLD}[4/5] Repository${NC}"
cd "$FORGEOS_DIR"
REMOTE="$(git config --get remote.origin.url 2>/dev/null || echo 'not set')"
ok "Remote: $REMOTE"
ok "Branch: $(git branch --show-current)"
ok "Vault: $FORGEOS_DIR/LIFE-OS-VAULT"

# ── Step 5: Start ──
echo -e "${BOLD}[5/5] Starting ForgeOS${NC}"
"$FORGEOS_DIR/forgeos" start

# ── Summary ──
echo ""
echo -e "${CYAN}${BOLD}  ── ForgeOS Bootstrap Complete ──${NC}"
if [ "$fail_count" -gt 0 ]; then
  echo -e "  ${YELLOW}$fail_count warnings — see above${NC}"
fi
echo ""
echo -e "  ${BOLD}Open these:${NC}"
echo -e "  📓  Vault:      $FORGEOS_DIR/LIFE-OS-VAULT/"
echo -e "  🖥️   Dashboard:  http://localhost:31337"
echo -e "  🦙  LLM API:    http://localhost:11434"
echo -e "  💬  Local Chat: Open LIFE-OS-VAULT/Tools/ollama-webui.html"
echo ""
echo -e "  ${BOLD}Try:${NC}"
echo -e "  ./forgeos status       — System status"
echo -e "  ./forgeos report       — New daily report"
echo -e "  ./Tools/ask-vault.sh \"your question\"  — RAG query"
