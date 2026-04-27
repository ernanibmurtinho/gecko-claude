# Working agreements — Gecko-powered project

This file ships with every Gecko install. It tells Claude Code how to behave inside a project that has the `gecko-claude` scaffold installed.

## Identity & credentials

- **The frames.ag wallet is the user's only credential.** Never ask for an API key. Never ask for a private key.
- The wallet's `apiToken` lives at `~/.agentwallet/config.json` (chmod 600). **Never log, echo, or paste it into conversation, errors, debug output, or commit messages.** If you're about to surface it accidentally, redact.
- Username (`@<username>`) is safe to display. Solana and EVM addresses are safe to display.

## Payment ground rules

- Every paid call uses x402 USDC on Solana via the user's frames.ag wallet. No exceptions.
- Quote the price **before** invoking a paid skill. Wait for explicit approval on amounts above $0.50.
- After a paid call, mention the on-chain transaction signature; the user can verify on Solana Explorer.
- Errors from frames.ag (`POLICY_DENIED`, `WALLET_FROZEN`, `insufficient_funds`, `PAYMENT_REJECTED`) are surfaced **verbatim**. Don't paraphrase. Each has a one-line remediation:
  - `POLICY_DENIED` → "Update with `gecko-mcp wallet policy --max-per-tx <USD>`"
  - `WALLET_FROZEN` → "Visit https://frames.ag to resolve"
  - `insufficient_funds` → "Fund at https://frames.ag/u/<username>"
  - `PAYMENT_REJECTED` → "Target API rejected the payment (target-side issue)"

## Project budgets

- `gecko project init <name> --budget <USD>` creates a budget envelope.
- v1: budget is policy-bounded (frames.ag enforces `max_per_tx_usd` server-side; we track per-project spend client-side).
- v2: cryptographic isolation via Privy-managed sub-wallets. UX stays identical.
- When invoking a paid skill in a project context, attach `--project <name>` so the spend lands on that project's tally.

## The PRD is the contract

When working with a `gecko_research` result, treat the output as a hard spec:

- `prd.v1_scope[]` — what to build first
- `acceptance_criteria[]` — how you know V1 is done
- `out_of_scope[]` — features explicitly excluded from V1
- `success_metrics[]` — measurable post-launch outcomes
- `sources[]` — every claim should trace here via citation

If a feature isn't cited by `v1_scope` or `acceptance_criteria`, **don't build it**. The user paid for the discipline.

## Sub-agent escalation

When the user has a `ResearchResult` and is ready to build:

1. **research-analyst** — exploration, free `gecko_ask` follow-ups against the corpus.
2. **market-validator** — pressure-test the validation_report. Recommends at most one paid follow-up.
3. **technical-architect** — translate `prd.v1_scope` into a tech plan (default: Next.js 15 + Tailwind + Supabase).
4. **validator** — last gate before code. Catches V2-in-disguise scope.
5. **builder** — writes code. Scaffolds via `npx create-next-app`. Stops at `acceptance_criteria`.

## Skills inventory

Free (no payment):
- `gecko-ask` — follow-up question against the indexed session
- `gecko-sources` — list indexed sources

Paid (priced in skill frontmatter):
- `gecko-research` — $0.10 basic / $0.75 pro
- `extract-page` — ~$0.004/URL (Tavily Extract for bot-walled pages)
- `fund-wallet` — orchestration only, no payment itself

## Anti-patterns

- **Re-running `gecko_research`** for follow-ups when `gecko_ask` would do. Charges a new $0.10.
- **Paying for sources you can read directly.** If a URL is publicly accessible, just fetch.
- **Inventing facts past the corpus.** Every non-trivial claim cites a source. No source → say so.
- **Ignoring `out_of_scope`.** If the PRD excluded auth in V1, push back when the user asks for auth.

## Minimum viable demo

```bash
gecko project init bonito-hotel-guide --budget 5.00
# In Claude Code:
Use gecko_research to validate: a hotel guide for Bonito MS in Brazil --project bonito-hotel-guide
gecko-mcp economics <session_id>
```

That sequence — paid validation, on-chain receipt, executable PRD — is the loop. Build from it.
