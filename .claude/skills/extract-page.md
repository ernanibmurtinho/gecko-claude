---
name: extract-page
description: Paid skill (~$0.004 USDC per URL) — extract clean text from a single web page via Tavily Extract, paid via the user's frames.ag wallet. Use when a page is bot-walled, JavaScript-rendered, or wasn't indexed by gecko_research.
---

# extract-page

## When to use

The user asks for content from a URL that:
- Returned 0 chunks in `gecko_sources` (extraction failed during research)
- Is freshness-sensitive (pricing pages, news, docs)
- Is bot-walled (booking.com, expedia, tripadvisor, similarweb, etc.)

Don't use for URLs the user can read directly — that's wasted USDC. Don't use for private/internal IPs (Tavily refuses, and we'd bill the user for a guaranteed failure).

## Cost

**~$0.004 USDC per URL** via Tavily Extract (advanced depth). Frames.ag's policy may bound this further.

**Always quote the cost and confirm with the user before invoking.** Format:

> "I'll extract `<URL>` via Tavily — costs ~$0.004 USDC from your frames.ag wallet. Proceed?"

## How to invoke

Use the `gecko-mcp wallet pay` command (or the equivalent MCP `extract` action when wired):

```
gecko-mcp wallet pay https://target-url.com --max-payment 0.005
```

Or programmatically through the MCP if available. The frames.ag wallet signs the x402 payment, Tavily returns clean markdown.

## What you get back

```json
{
  "url": "https://target-url.com",
  "raw_content": "<extracted markdown>",
  "extracted_at": "2026-04-27T..."
}
```

The `raw_content` lands in your context. Cite it back to the user with the URL — same citation discipline as the corpus.

## Don't

- Skip the cost confirmation. Even small charges deserve a yes.
- Run extract on >3 URLs in a single user request. If they need more, suggest a fresh `gecko_research` with the URLs as seeds (one $0.10 vs many $0.004 — depending on count, research wins).
- Use on private network URLs, file://, or anything Tavily can't reach. Test the URL with the user first.
- Forget to surface frames.ag errors verbatim if payment fails (`POLICY_DENIED`, `insufficient_funds`).
