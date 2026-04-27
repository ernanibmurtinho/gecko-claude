---
name: gecko
description: Bootstrap a Gecko-powered project in Claude Code. Installs gecko-mcp, connects the user's frames.ag wallet via email + OTP (no browser), prompts funding, and runs a first paid research call. No API keys, no signup beyond the wallet.
---

# Gecko — Builder Bootstrap Platform

When a user pastes "Read https://app.geckovision.tech/skill.md and follow the instructions" into Claude Code, you (Claude) walk them through the four steps below. Every cent of payment runs on x402 over Solana via the user's frames.ag wallet.

## What you're installing

One MCP server (`gecko-mcp`) exposing three tools:

| Tool | What it does | Cost |
|---|---|---|
| `gecko_research` | Discover sources → index → generate business plan + validation + PRD | **$0.10 (basic) / $0.75 (pro)** USDC |
| `gecko_ask` | Follow-up question grounded in the session's indexed corpus | free |
| `gecko_sources` | List indexed sources for the session | free |

Plus 5 pre-baked sub-agents (`research-analyst`, `market-validator`, `technical-architect`, `validator`, `builder`) and 5 skills wrapping the tools above + `extract-page` (paid Tavily) and `fund-wallet`.

## Step 1 — Run the installer

```bash
curl -fsSL https://app.geckovision.tech/install.sh | bash
```

This does (Claude: confirm with the user before running): verify Python 3.11+, install `uv` if missing, `uv tool install gecko-mcp`, copy `.claude/` + `CLAUDE.md` + `.mcp.json` into the current directory, register `gecko` with Claude Code via `claude mcp add`. Idempotent on re-run.

## Step 2 — Connect the user's frames.ag wallet (inside Claude Code, no browser)

**First check `~/.agentwallet/config.json`.** If it exists with `apiToken`, the user is already connected — skip to Step 3 with "Already connected as @<username>."

Otherwise:

1. Ask the user for their email.
2. `POST https://frames.ag/api/connect/start` with `{"email": "<email>"}` → returns `{username, ...}`. Save `username` for the next call.
3. Tell the user: "I sent a 6-digit code to <email>. Paste it back here." Wait for OTP.
4. `POST https://frames.ag/api/connect/complete` with `{"username": "<u>", "email": "<email>", "otp": "<6 digits>"}` → returns `{apiToken, evmAddress, solanaAddress, ...}`.
5. Save to `~/.agentwallet/config.json` with `chmod 600`. **Never echo the apiToken.** Confirm to the user with username + Solana address only.
6. On error: bad OTP → frames returns 401, ask the user to try again; expired OTP → frames returns 400, restart from step 1; frames 5xx → tell the user frames is having issues, retry in a minute.

## Step 3 — Fund the wallet

Print: `https://frames.ag/u/<username>` and tell the user "Open this in your browser to fund your wallet via Coinbase Onramp (PIX in Brazil, card/bank elsewhere). $5 USDC covers ~50 basic research sessions. Come back here when funded."

Optionally invoke the `fund-wallet` skill for full instructions on funding alternatives.

After they confirm funding: `gecko-mcp wallet balance` to verify. Don't proceed to Step 4 until balance > session price.

## Step 4 — First research

Suggest:

```
Use gecko_research to validate: <their idea, prompt if they don't have one>
```

Quote the $0.10 price. On approval, the MCP tool fires; payment settles in 5-10s; the workflow runs ~60s; full ResearchResult lands in your context (business_plan, validation_report, prd, sources, session_id, x402_tx_signature).

After the result lands, show:
- `gecko-mcp economics <session_id>` — cost/margin breakdown with the on-chain tx.
- Solana Explorer URL for the tx signature.

Hand off to the `research-analyst` sub-agent for exploration, or the `market-validator` if the user wants to stress-test the validation report.

## Notes for Claude Code

- The frames.ag apiToken (`mf_...`) is the user's only credential. **Never log, echo, or paste it into conversation, errors, or commit messages.** Treat like a password.
- The `~/.agentwallet/config.json` file is `chmod 600` and gitignored. Never commit.
- Surface frames.ag errors verbatim: `POLICY_DENIED`, `WALLET_FROZEN`, `insufficient_funds`, `PAYMENT_REJECTED`. Don't paraphrase. Each has a short remediation in `CLAUDE.md`.
- First-time users almost always need Step 3. Don't skip it; the demo dies on insufficient funds.
- Browse other Gecko skills at `https://app.geckovision.tech/skills/`.

---

*Builder Bootstrap Platform · geckovision.tech · No API keys. Just a wallet.*
