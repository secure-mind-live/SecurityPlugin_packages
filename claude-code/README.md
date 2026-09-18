# Claude Code Integration

SecurityPlugin integrates with Claude Code via **hooks** — shell commands that fire at specific lifecycle points, blocking sensitive actions before they execute.

## Quick Setup

```bash
# From the SecurityPlugin_packages root:
chmod +x setup-claude-code.sh
./setup-claude-code.sh
```

Or manually:

```bash
# 1. Install the core package
pip install securityagent-core

# 2. Set the root path (add to your shell profile)
export SECURITY_AGENT_ROOT=$(pip show securityagent-core | grep Location | cut -d' ' -f2)/securityagent_core

# 3. Copy hooks config to your project
cp claude-code/settings.json /path/to/your/project/.claude/settings.json
```

## How It Works

| Hook | Fires When | What It Does |
|------|-----------|-------------|
| `PreToolUse(Read)` | Claude reads a file | Blocks `.env`, credentials, PII via DLP scan |
| `PreToolUse(Bash)` | Claude runs a command | Blocks `cat ~/.env`, `printenv`, exfiltration |
| `PreToolUse(Edit\|Write)` | Claude edits/writes a file | Blocks edits to sensitive files |
| `UserPromptSubmit` | User submits a prompt | 3-layer intent analysis for sensitive data requests |

Exit code 2 = **hard block**. Claude Code will not execute the tool.

## Verify

```bash
# In a Claude Code session, try:
# "Read ~/.env"           → BLOCKED
# "Read README.md"        → ALLOWED
# "Run: cat ~/.env"       → BLOCKED
# "Run: echo hello"       → ALLOWED
```
