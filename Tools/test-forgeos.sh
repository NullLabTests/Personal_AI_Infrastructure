#!/usr/bin/env bash
# test-forgeos.sh — Validate ForgeOS repo integrity
set -euo pipefail
fail=0

RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; NC='\033[0m'
ok()  { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; fail=$((fail+1)); }

header() { echo -e "\n${BOLD}$1${NC}"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

header "1. Repository Structure"
[ -f forgeos ] && [ -x forgeos ] && ok "forgeos CLI exists and executable" || fail "forgeos CLI missing"
[ -f setup.sh ] && [ -x setup.sh ] && ok "setup.sh exists and executable" || fail "setup.sh missing"
[ -f README.md ] && ok "README.md exists" || fail "README.md missing"
[ -f LICENSE ] && ok "LICENSE exists" || fail "LICENSE missing"
[ -d .github/ISSUE_TEMPLATE ] && ok "Issue templates exist" || fail "Issue templates missing"

header "2. Vault Structure"
[ -d LIFE-OS-VAULT ] && ok "Vault root exists" || fail "Vault root missing"
for stack in 01_Cognition 02_Body 03_Capital 04_Relationships 05_Impact; do
  [ -d "LIFE-OS-VAULT/$stack" ] && ok "  $stack/" || fail "  $stack/ missing"
  [ -f "LIFE-OS-VAULT/$stack/README.md" ] && ok "  $stack/README.md" || fail "  $stack/README.md missing"
  [ -f "LIFE-OS-VAULT/$stack/Dashboard.md" ] && ok "  $stack/Dashboard.md" || fail "  $stack/Dashboard.md missing"
done

header "3. Vault Templates"
[ -f "LIFE-OS-VAULT/01_Cognition/Decision-Log/TEMPLATE.md" ] && ok "Decision Log template" || fail "Decision Log template missing"
[ -f "LIFE-OS-VAULT/01_Cognition/Monthly-Review-Template.md" ] && ok "Monthly Review template" || fail "Monthly Review template missing"
[ -f "LIFE-OS-VAULT/04_Relationships/People/TEMPLATE.md" ] && ok "People note template" || fail "People note template missing"
[ -f "LIFE-OS-VAULT/03_Capital/Budget/budget-template.csv" ] && ok "Budget CSV template" || fail "Budget CSV template missing"

header "4. Dataview Queries"
[ -f "LIFE-OS-VAULT/01_Cognition/Dataview-Example-Queries.md" ] && ok "Dataview examples exist" || fail "Dataview examples missing"
DV_COUNT=$(grep -c '```dataview' LIFE-OS-VAULT/01_Cognition/Dataview-Example-Queries.md 2>/dev/null || echo 0)
[ "$DV_COUNT" -ge 3 ] && ok "  $DV_COUNT Dataview query blocks" || fail "  Less than 3 query blocks"

header "5. README Polish"
grep -qE 'screenshot-pulse-dashboard|demo-pulse-dashboard' README.md && ok "Pulse screenshot referenced" || fail "Pulse screenshot not in README"
grep -q 'screenshot-vault-tree.png' README.md && ok "Vault tree screenshot referenced" || fail "Vault tree screenshot not in README"
grep -q 'setup.sh' README.md && ok "setup.sh referenced" || fail "setup.sh not in README"
grep -q 'forgeos' README.md && ok "forgeos CLI referenced" || fail "forgeos CLI not in README"
BADGE_COUNT=$(grep -c 'img.shields.io' README.md || true)
[ "$BADGE_COUNT" -ge 8 ] && ok "  $BADGE_COUNT badges" || fail "  Only $BADGE_COUNT badges"

header "6. Assets"
[ -f assets/screenshot-pulse-dashboard.png ] && ok "Pulse dashboard screenshot ($(du -h assets/screenshot-pulse-dashboard.png | cut -f1))" || fail "Pulse screenshot missing"
[ -f assets/demo-pulse-dashboard.gif ] && ok "Pulse dashboard GIF ($(du -h assets/demo-pulse-dashboard.gif | cut -f1))" || fail "Pulse demo GIF missing"
[ -f assets/screenshot-vault-tree.png ] && ok "Vault tree screenshot ($(du -h assets/screenshot-vault-tree.png | cut -f1))" || fail "Vault tree screenshot missing"
[ -f assets/five-stacks-diagram.md ] && ok "Architecture diagram exists" || fail "Architecture diagram missing"

header "7. Git Health"
git rev-parse --git-dir &>/dev/null && ok "Git repository" || fail "Not a git repo"
REMOTE=$(git config --get remote.origin.url 2>/dev/null || echo "")
[ -n "$REMOTE" ] && ok "Remote: $REMOTE" || fail "No remote configured"
UNSTAGED=$(git status --short | wc -l)
[ "$UNSTAGED" -eq 0 ] && ok "Clean working tree" || echo "    ~ $UNSTAGED unstaged file(s) (pre-commit state)"

header "8. Ollama (optional)"
if command -v ollama &>/dev/null; then
  if curl -s --max-time 3 http://localhost:11434/api/tags &>/dev/null; then
    ok "Ollama running"
    MODELS=$(ollama list 2>/dev/null | wc -l)
    [ "$MODELS" -ge 2 ] && ok "  $((MODELS-1)) models available" || fail "  Less than 2 models"
  else
    echo "  ! Ollama installed but not running"
  fi
else
  echo "  - Ollama not installed (optional)"
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}All tests passed.${NC}"
else
  echo -e "  ${RED}${BOLD}$fail test(s) failed.${NC}"
  exit 1
fi
