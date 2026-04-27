---
name: gecko-ask
description: Free follow-up question against an existing Gecko research session's indexed knowledge base. Returns an answer grounded in the same sources gecko_research used. Use after a gecko_research call when the user wants to drill in.
---

# gecko_ask

## When to use

After a `gecko_research` call has indexed sources for a session, use this for any follow-up question. Cheaper and faster than re-running research.

Examples:
- "Tell me more about competitor X mentioned in the validation report"
- "What does the corpus say about pricing?"
- "Which source mentioned the regulatory risk?"
- "Summarize the business model in two sentences"

## Cost

**Free.** It's a RAG query against the existing session's chunks. No payment, no x402.

## How to invoke

Through the `gecko_ask` MCP tool. Requires the `session_id` from a prior `gecko_research` call:

```
Use gecko_ask on session <session_id>: <question>
```

If the user doesn't specify a session, default to their most recent one (Claude can usually infer from context).

## What you get back

```json
{
  "answer": "<grounded answer>",
  "citations": [{"source_id": "...", "title": "...", "url": "...", "excerpt": "..."}]
}
```

Every claim in `answer` traces to a `citations[].source_id`. If the corpus doesn't cover the question, `answer` says so directly — don't synthesize from priors.

## Don't

- Hallucinate beyond the citations. If `gecko_ask` says "the corpus doesn't cover this," repeat that to the user; don't fill the gap from your own knowledge.
- Re-run `gecko_research` to "refresh" — that's a new $0.10. The session's index is already stable.
- Skip the citations when relaying the answer. Always show the source.
