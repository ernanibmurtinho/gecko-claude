# gecko-claude — Implementation Breakdown

The user-facing repo. Ships pre-Shipathon. MIT, public, forkable. Distribution surface for the Gecko platform: one curl install, one MCP server, five skills, five agents.

Reference: `gecko-mcpay-api/docs/user-facing-repo-plan.md` (the plan), `auth-frames-bearer.md` (auth), `scaffold-and-pro-tier-plan.md` (roadmap).

## Tickets-to-file

| # | Path | Purpose | Owner | Acceptance |
|---|---|---|---|---|
| 1 | `install.sh` | Bootstrap: detect OS/python/uv/claude, `uv tool install gecko-mcp`, copy `.claude/` + `CLAUDE.md` + `.mcp.json` into target dir, register MCP server. | software | Runs clean on macOS + Linux, idempotent on re-run, aborts on Windows with WSL hint, exits non-zero on any precondition fail. |
| 2 | `README.md` | One-line install + 60-second demo gif + link to `app.geckovision.tech/skill.md`. | business | New visitor can install and run `gecko_research` in <2min reading only README. |
| 3 | `LICENSE` | MIT, copyright Gecko. | staff | SPDX-compliant MIT text, current year. |
| 4 | `CLAUDE.md` | Working agreements for Claude Code in user projects: never log apiToken, the wallet is the only credential, x402 ground rules, skill index. | staff | Mirrors tone of `gecko-mcpay-api/CLAUDE.md`; references all 5 skills + 5 agents by name. |
| 5 | `skill.md` | Public bootstrap doc served at `app.geckovision.tech/skill.md`. ~350 words. Frontmatter + 4 numbered steps (install, connect wallet via OTP, fund, first research). | staff | Renders correctly on the static host; copy-pasteable commands; no API keys requested anywhere. |
| 6 | `.mcp.json.template` | Pre-registered placeholders for `gecko` (stdio: `gecko-mcp serve`) and `supabase` (read-only schema introspection, optional). | software | `claude mcp list` shows `gecko` after install; template has no real secrets. |
| 7 | `.claude/skills/gecko-research.md` | Wraps the paid `gecko_research` MCP tool. Names the price ($0.10), describes JSON return shape (`business_plan`, `validation_report`, `prd`, `sources`). | software | Skill is invoked when user says "validate this idea"; quotes price before call. |
| 8 | `.claude/skills/gecko-ask.md` | Free follow-up question against the indexed session corpus. | software | Returns citations from `sources[]`, never hallucinates beyond them. |
| 9 | `.claude/skills/gecko-sources.md` | Free; lists sources for the current/last session. | software | Returns the `sources[]` array with titles + URLs; no LLM call. |
| 10 | `.claude/skills/extract-page.md` | Paid Tavily Extract via frames.ag x402 ($0.004/URL). | web3 | Names the price; refuses on private/file URLs; returns extracted markdown. |
| 11 | `.claude/skills/fund-wallet.md` | Opens `frames.ag/u/{username}` and tells user to run `gecko-mcp doctor` after funding. | web3 | Reads username from `~/.agentwallet/config.json`; never echoes apiToken. |
| 12 | `.claude/agents/research-analyst.md` | Persona — explores `ResearchResult` deeper via `gecko_ask`. | staff | Frontmatter + role-specific body; cites the schema. |
| 13 | `.claude/agents/market-validator.md` | Persona — adversarial reader of `validation_report`. | business | Identifies one paid follow-up worth running, or says "skip." |
| 14 | `.claude/agents/technical-architect.md` | Persona — translates `prd.v1_scope` into Next.js 15 + Tailwind + Supabase choices. | staff | Doesn't invent features outside `acceptance_criteria`. |
| 15 | `.claude/agents/validator.md` | Persona — pre-implementation PRD review; catches V2-in-disguise scope. | staff | Has a named anti-pattern list. |
| 16 | `.claude/agents/builder.md` | Persona — scaffolds via `npx create-next-app` on demand, implements V1 only. | software | Cites the PRD line driving each commit; stops at acceptance criteria. |
| 17 | `docs/flow.md` | Sequence diagram: install → OTP → fund → research → agents → ship. | staff | One mermaid diagram; matches §4 of `user-facing-repo-plan.md`. |

## PR-ready acceptance checklist

Reviewer must verify before merging the first commit:

- [ ] `bash install.sh` on a clean macOS box completes in <90s
- [ ] `claude mcp list` shows `gecko` post-install
- [ ] `skill.md` renders at `app.geckovision.tech/skill.md` (302 from install URL works)
- [ ] All 5 skills declare price (or "free") in their frontmatter description
- [ ] All 5 agents have `name`, `description`, body sections (mission/principles/anti-patterns/workflows)
- [ ] No secrets in repo: `git grep -E "mf_|sk-|sb_"` returns empty
- [ ] LICENSE is MIT
- [ ] README one-liner curl URL matches the deployed install URL
- [ ] `CLAUDE.md` references the 5 skills + 5 agents by exact filename
- [ ] `.mcp.json.template` has no real keys; placeholders are `${VAR}` form
- [ ] `docs/flow.md` mermaid renders on GitHub
- [ ] `gecko_research` smoke run completes end-to-end in stub mode

## Status

**staff-engineer (this dispatch):**
- All 5 sub-agent persona files (`.claude/agents/*.md`) — shipped
- This implementation breakdown — shipped

**software-engineer (in flight):**
- install.sh, README.md, LICENSE, CLAUDE.md, .mcp.json.template
- 4 skills: gecko-research.md, gecko-ask.md, gecko-sources.md, extract-page.md

**web3-engineer (in flight):**
- skill.md (the master entry point)
- .claude/skills/fund-wallet.md
