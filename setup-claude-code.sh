#!/usr/bin/env bash
# ============================================================
# SecurityPlugin — Claude Code Setup
# ============================================================
# Installs securityagent-core and configures Claude Code hooks
# for DLP protection in your project.
# ============================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BOLD}SecurityPlugin — Claude Code Setup${NC}"
echo ""

# Step 1: Install securityagent-core
echo -e "${BOLD}[1/3]${NC} Installing securityagent-core..."
if pip install securityagent-core 2>/dev/null; then
    echo -e "  ${GREEN}Installed${NC}"
else
    echo -e "  ${RED}Failed to install securityagent-core.${NC}"
    echo "  Make sure pip is available and try: pip install securityagent-core"
    exit 1
fi

# Step 2: Find the package location
CORE_PATH=$(python3 -c "import securityagent_core; import os; print(os.path.dirname(securityagent_core.__file__))" 2>/dev/null)
if [ -z "$CORE_PATH" ]; then
    echo -e "  ${RED}Could not locate securityagent-core package.${NC}"
    exit 1
fi

SCRIPTS_DIR="$(dirname "$CORE_PATH")"
echo -e "  Package at: $CORE_PATH"

# Step 3: Set up SECURITY_AGENT_ROOT
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SECURITY_AGENT_ROOT="$SCRIPT_DIR"

echo -e "\n${BOLD}[2/3]${NC} Setting SECURITY_AGENT_ROOT..."
echo "  SECURITY_AGENT_ROOT=$SECURITY_AGENT_ROOT"

# Add to shell profile if not already there
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "SECURITY_AGENT_ROOT" "$SHELL_PROFILE" 2>/dev/null; then
        echo "" >> "$SHELL_PROFILE"
        echo "# SecurityPlugin — Claude Code DLP hooks" >> "$SHELL_PROFILE"
        echo "export SECURITY_AGENT_ROOT=\"$SECURITY_AGENT_ROOT\"" >> "$SHELL_PROFILE"
        echo -e "  ${GREEN}Added to $SHELL_PROFILE${NC}"
    else
        echo -e "  Already in $SHELL_PROFILE"
    fi
fi

# Step 4: Show next steps
echo -e "\n${BOLD}[3/3]${NC} Copy hooks to your project:"
echo ""
echo "  cp $SCRIPT_DIR/claude-code/settings.json /path/to/your/project/.claude/settings.json"
echo ""
echo -e "${GREEN}${BOLD}Done!${NC} Restart your terminal, then open Claude Code in your project."
echo ""
echo "Test it:"
echo '  "Read ~/.env"           → BLOCKED'
echo '  "Read README.md"        → ALLOWED'
echo '  "Run: cat ~/.env"       → BLOCKED'
echo '  "Run: echo hello"       → ALLOWED'
