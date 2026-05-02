#!/usr/bin/env bash
# =============================================================================
# Docker smoke test for install.sh
#
#   ./test-install.sh
#
# Spins up a clean ubuntu:24.04 container, installs the minimal prereqs that
# the user is expected to already have (curl, python3, ca-certificates), then
# runs the canonical pipe-to-bash flow:
#
#   curl -fsSL https://raw.githubusercontent.com/ernanibmurtinho/gecko-claude/main/install.sh | bash
#
# Exits 0 only if `bb --help` runs successfully after install. Note: this
# fetches the install.sh from GitHub `main`, so it tests the *committed*
# version, not local edits. Run AFTER you push to main.
#
# A stub `claude` binary is dropped on PATH so the install.sh prereq check
# passes without bringing the full Node-based Claude Code CLI into the test
# image. The MCP-registration step is skipped via --no-mcp-register; the
# acceptance criterion is "bb is on PATH", not "MCP registers in CI".
# =============================================================================
set -euo pipefail

GECKO_CLAUDE_REPO="${GECKO_CLAUDE_REPO:-ernanibmurtinho/gecko-claude}"
GECKO_CLAUDE_REF="${GECKO_CLAUDE_REF:-main}"
INSTALL_URL="https://raw.githubusercontent.com/${GECKO_CLAUDE_REPO}/${GECKO_CLAUDE_REF}/install.sh"

echo "▸ Docker smoke test: ${INSTALL_URL}"

docker run --rm ubuntu:24.04 bash -c '
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq curl python3 ca-certificates >/dev/null

  # Stub claude binary so install.sh prereq check passes. Real Claude Code
  # CLI install requires Node and is out of scope for this smoke test —
  # the acceptance gate is "bb on PATH", which the prereq check gates.
  printf "#!/bin/sh\nexit 0\n" >/usr/local/bin/claude
  chmod +x /usr/local/bin/claude

  cd /tmp && mkdir -p workdir && cd workdir
  curl -fsSL '"${INSTALL_URL}"' | bash -s -- --no-mcp-register

  export PATH="$HOME/.local/bin:$PATH"
  command -v bb
  bb --help >/dev/null
  echo "PASS: bb installed and --help succeeded"

  # Idempotency: re-running must not crash.
  curl -fsSL '"${INSTALL_URL}"' | bash -s -- --no-mcp-register --force
  bb --help >/dev/null
  echo "PASS: re-run idempotent"
'

echo "▸ Docker smoke test: PASS"
