---
name: gecko-research
description: Run a paid Gecko research session — validate a startup idea, get a business plan + validation report + V1/V2/V3-scoped PRD with citations. Costs $0.10 (basic) or $0.75 (pro). Returns a ResearchResult. Use when the user wants to validate or scope an idea from scratch.
---

# gecko_research

## When to use

The user wants to:
- validate a startup idea ("is this a good idea?")
- get a PRD they can build from
- have an agent gather sources + reason over them in 60s
- start a project with a real, citation-backed brief

If they already ran research and want a follow-up, use `gecko-ask` instead — it's free.

## Cost

- **Basic:** $0.10 USDC (single-pass orchestration via gpt-4o-mini)
- **Pro:** $0.75 USDC (5-specialist AG2 GroupChat — research analyst, market analyst, technical architect, validator)

Always quote the price before invoking. Default to **basic** unless the user asks for pro or the idea is genuinely complex (regulated industries, deep technical, multi-sided market).

## How to invoke

Through the `gecko_research` MCP tool. Optional `--project <name>` to attach to a budget envelope.

```
Use gecko_research to validate: <plain-language idea, 1-2 sentences>
```

For pro tier:

```
Use gecko_research with tier=pro to validate: <idea>
```

## What you get back

A `ResearchResult` JSON with:

- `business_plan` — problem, audience, value prop, monetization, GTM
- `validation_report` — `demand_signals[]`, `competitor_landscape`, `risks[]`, `confidence_score`
- `prd` — `v1_scope[]`, `acceptance_criteria[]`, `success_metrics[]`, `out_of_scope[]`
- `sources` — `[{id, title, url, type, excerpt}]`
- `session_id` — UUID for follow-ups (`gecko_ask`, `gecko_sources`, `gecko-mcp economics`)
- `x402_tx_signature` — on-chain receipt

## After it lands

1. Show the user `gecko-mcp economics <session_id>` for the cost/margin breakdown.
2. Hand off to the `research-analyst` sub-agent to explore the result.
3. If the user wants to build, escalate through `market-validator` → `technical-architect` → `validator` → `builder`.

## Don't

- Re-run `gecko_research` for follow-ups. That charges another $0.10. Use `gecko_ask`.
- Invoke without quoting the price.
- Skip the `--project` flag if the user is in a project directory (check for `.gecko/project.json`).
