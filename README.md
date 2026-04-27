# Gecko — Builder Bootstrap Platform

> Turn a startup idea into a validated brief, paid for on-chain, ready for Claude Code to build.

One Claude Code skill. Three MCP tools. Real Solana payments via [frames.ag](https://frames.ag). No API keys, no signup, no credit card — just a wallet.

## Install

```bash
curl -fsSL https://app.geckovision.tech/install.sh | bash
```

Then open Claude Code in the same directory and paste:

```
Read https://app.geckovision.tech/skill.md and follow the instructions.
```

Claude walks you through wallet setup (email + OTP, ~30 seconds) and funding (~$5 USDC covers ~50 sessions).

## What you get

- **`gecko_research`** — Validate any idea. Returns a business plan, validation report with citations, and a V1/V2/V3-scoped PRD. **$0.10 (basic) or $0.75 (pro multi-agent).**
- **`gecko_ask`** — Free follow-ups grounded in the indexed sources.
- **`gecko_sources`** — Free; lists every source with chunk counts.
- **Per-project budgets** — `gecko project init my-idea --budget 5.00` — soft cap enforced in v1, cryptographically isolated in v2.
- **On-chain receipts** — every paid call has a real Solana transaction signature. `gecko-mcp economics <session_id>` shows the margin math.

## How it works

```
1. You paste one line into Claude Code
   ↓
2. Claude orchestrates: install → wallet OTP → fund prompt → MCP register
   ↓
3. You ask for research: "Use gecko_research to validate: <idea>"
   ↓
4. frames.ag wallet pays $0.10 USDC on Solana → gecko-api runs the workflow
   ↓
5. Full PRD lands in your context. Sub-agents help you build from it.
```

## Cost transparency

Per session at $0.10 retail:

| Line | Real cost |
|---|---|
| LLM (gpt-4o-mini orchestration) | $0.0030 |
| Embeddings (text-embedding-3-small) | $0.0012 |
| Tavily (source discovery) | $0.0080 |
| **Total** | **$0.0122** |
| **Margin** | **$0.088 (88%)** |

Run `gecko-mcp economics <session_id>` after any session to see the full breakdown.

## Sub-agents (`.claude/agents/`)

After your `gecko_research` lands, five pre-baked personas help you build:

- **research-analyst** — explore the result, run free `gecko_ask` follow-ups
- **market-validator** — adversarial reader of the validation report
- **technical-architect** — translate `prd.v1_scope` into Next.js + Tailwind + Supabase
- **validator** — pre-implementation sanity check (catches V2-in-disguise scope)
- **builder** — scaffolds via `npx create-next-app`, implements V1 only

## Skills (`.claude/skills/`)

- `gecko-research.md` — paid validation
- `gecko-ask.md` — free follow-ups
- `gecko-sources.md` — free; list sources
- `extract-page.md` — paid Tavily Extract (~$0.004/URL) for bot-walled pages
- `fund-wallet.md` — wallet topping-up flow

## Roadmap

- v1 (this repo) — terminal-first; project budgets policy-bounded.
- v2 — Privy direct integration for cryptographic per-project wallet isolation.
- v3 — branded frontend at `app.geckovision.tech` for project dashboards + economics charts.

See [`gecko-mcpay-api/docs/`](https://github.com/geckovision/gecko-mcpay-api/tree/main/docs) for the full plans.

## License

MIT. See [`LICENSE`](./LICENSE).
