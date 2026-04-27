---
name: gecko-sources
description: Free; list every source indexed for a Gecko research session — URL, title, type, chunk count, indexed_at. Use when the user asks "what did you read?" or wants to verify a citation.
---

# gecko_sources

## When to use

The user wants transparency on what `gecko_research` actually read:
- "What sources did you use?"
- "Which URLs are in the index?"
- "Did you read source X?"

Also useful before suggesting a paid `extract-page` — first check whether the URL is already in the corpus.

## Cost

**Free.** Pure database read. No LLM call, no payment.

## How to invoke

Through the `gecko_sources` MCP tool with the `session_id`:

```
Use gecko_sources on session <session_id>
```

## What you get back

A list of source records:

```json
[
  {
    "url": "https://example.com/article",
    "type": "web",
    "chunk_count": 12,
    "indexed_at": "2026-04-27T..."
  },
  ...
]
```

`chunk_count = 0` means the URL was discovered but extraction failed (bot-walled, dead link). For those, the user can run `extract-page` (paid) to retry via Tavily's scraper.

## Common workflows

- **Verify a citation:** user asks "where did claim X come from?" → call `gecko_ask` first to get the source_id, then `gecko_sources` to show the user the URL list.
- **Identify failed sources:** filter for `chunk_count == 0` and offer `extract-page` on the most relevant one.
- **Show the work:** when reporting a `gecko_research` result, list the sources at the bottom — builds user trust.
