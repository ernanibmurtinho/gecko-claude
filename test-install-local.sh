#!/usr/bin/env bash
# =============================================================================
# Local dry-run for install.sh — no Docker required.
#
#   ./test-install-local.sh
#
# Runs ./install.sh against a temporary HOME and a temporary working dir, with
# a stub `claude` binary so the prereq check passes. Asserts `bb --help`
# works against the freshly-installed tool. Cleans up on exit.
#
# This is the CI-friendly variant of test-install.sh. Use it before pushing
# changes to install.sh — it exercises your local edits, where test-install.sh
# only exercises whatever is on GitHub `main`.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SH="${SCRIPT_DIR}/install.sh"

if [ ! -f "${INSTALL_SH}" ]; then
  echo "install.sh not found at ${INSTALL_SH}" >&2
  exit 1
fi

# Prereq sanity: require python3 >=3.11 on the host. The script itself checks
# this, but failing fast here gives a clearer error than a piped-bash trace.
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)' || {
  echo "Python 3.11+ required on host" >&2
  exit 1
}

TMP_HOME="$(mktemp -d)"
TMP_WORK="$(mktemp -d)"
TMP_BIN="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_HOME}" "${TMP_WORK}" "${TMP_BIN}"
}
trap cleanup EXIT

# Stub `claude` so install.sh prereq passes. The MCP-registration branch is
# skipped via --no-mcp-register; the acceptance gate is "bb on PATH".
printf '#!/bin/sh\nexit 0\n' >"${TMP_BIN}/claude"
chmod +x "${TMP_BIN}/claude"

echo "▸ Local dry-run"
echo "  HOME=${TMP_HOME}"
echo "  cwd=${TMP_WORK}"

# Use the local checkout for the scaffold copy so we don't hit the network
# for the gecko-claude tarball. gecko-mcp itself still goes through PyPI
# (or the GitHub fallback) — that's the install path we want to test.
cd "${TMP_WORK}"
HOME="${TMP_HOME}" \
  PATH="${TMP_BIN}:${TMP_HOME}/.local/bin:${PATH}" \
  GECKO_CLAUDE_REPO_LOCAL="${SCRIPT_DIR}" \
  bash "${INSTALL_SH}" --no-mcp-register

# Verify bb is installed and runs.
export PATH="${TMP_HOME}/.local/bin:${PATH}"
if ! command -v bb >/dev/null 2>&1; then
  echo "FAIL: bb not on PATH after install" >&2
  exit 1
fi
HOME="${TMP_HOME}" bb --help >/dev/null
echo "PASS: bb --help"

# Idempotency check — second run on a clean .claude/ requires --force.
cd "${TMP_WORK}"
HOME="${TMP_HOME}" \
  PATH="${TMP_BIN}:${TMP_HOME}/.local/bin:${PATH}" \
  GECKO_CLAUDE_REPO_LOCAL="${SCRIPT_DIR}" \
  bash "${INSTALL_SH}" --no-mcp-register --force
HOME="${TMP_HOME}" bb --help >/dev/null
echo "PASS: re-run idempotent"

echo "▸ Local dry-run: PASS"
