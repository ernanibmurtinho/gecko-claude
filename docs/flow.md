# End-to-end flow

The Gecko user journey, from one pasted line in Claude Code to a paid, on-chain-receipted research result with a full PRD ready for the `builder` sub-agent.

## Sequence

```mermaid
sequenceDiagram
    participant U as User
    participant CC as Claude Code
    participant Sh as install.sh
    participant GMCP as gecko-mcp (local)
    participant FA as frames.ag
    participant GAPI as api.geckovision.tech
    participant FAC as x402 facilitator
    participant SOL as Solana devnet/mainnet

    Note over U,CC: 1. One-line bootstrap

    U->>CC: paste "Read https://app.geckovision.tech/skill.md..."
    CC->>Sh: curl -fsSL .../install.sh | bash
    Sh->>Sh: verify python3.11+, uv, claude CLI
    Sh->>GMCP: uv tool install gecko-mcp
    Sh->>CC: copy .claude/, CLAUDE.md, .mcp.json
    Sh->>CC: claude mcp add gecko -- gecko-mcp serve
    Sh-->>CC: banner: "paste skill.md URL"

    Note over U,FA: 2. Wallet connect (inside Claude Code, no browser)

    CC->>U: "What's your email?"
    U-->>CC: email
    CC->>FA: POST /api/connect/start {email}
    FA-->>CC: {username}
    FA-->>U: emails 6-digit OTP
    CC->>U: "I sent a code to <email>. Paste it back."
    U-->>CC: 6-digit OTP
    CC->>FA: POST /api/connect/complete {username, email, otp}
    FA-->>CC: {apiToken, evmAddress, solanaAddress}
    CC->>CC: write ~/.agentwallet/config.json (chmod 600, never echo apiToken)
    CC-->>U: "Connected as @<username>. Solana: <addr>"

    Note over U,SOL: 3. Funding

    CC->>U: "Fund at https://frames.ag/u/<username>. $5 ≈ 50 sessions."
    U->>FA: opens frames.ag/u/<username> in browser
    FA->>U: Coinbase Onramp (PIX / card / bank)
    U->>FA: $5 USDC purchase
    FA-->>SOL: USDC transfer to user's frames wallet

    Note over U,SOL: 4. First research call

    U->>CC: "Use gecko_research to validate: <idea>"
    CC->>GMCP: gecko_research(idea, project_id?)
    GMCP->>FA: POST /actions/x402/fetch (api.geckovision.tech/research)
    FA->>GAPI: POST /research (no payment)
    GAPI-->>FA: 402 + payment-required
    FA->>SOL: signs USDC transfer ($0.10)
    FA->>GAPI: POST /research + PAYMENT-SIGNATURE
    GAPI->>FAC: verify(payment)
    FAC-->>GAPI: isValid: true
    GAPI-->>FA: 202 {session_id, status, poll_url}
    GAPI->>FAC: settle(payment)
    FAC->>SOL: submit on-chain tx
    SOL-->>FAC: tx signature
    FAC-->>GAPI: {success, tx}
    FA-->>GMCP: 202 + payment-response header (real tx)

    par background workflow
        GAPI->>GAPI: Tavily discover sources
        GAPI->>GAPI: extract + chunk + embed
        GAPI->>GAPI: orchestrate via OpenAI
        GAPI->>GAPI: persist result_json
    and MCP polls
        loop every 4s
            GMCP->>GAPI: GET /sessions/{id}/result
            GAPI-->>GMCP: 425 still processing
        end
    end

    GAPI-->>GMCP: 200 + ResearchResult JSON
    GMCP-->>CC: ResearchResult (business_plan, validation_report, prd, sources)
    CC-->>U: renders the result

    Note over U,CC: 5. Build from the brief

    U->>CC: "now build the V1"
    CC->>CC: research-analyst → market-validator → technical-architect → validator → builder
    CC->>CC: builder runs npx create-next-app
    CC-->>U: V1 app, citing PRD lines per commit
```

## Caption

The whole loop runs in roughly **3 minutes** from cold install to a research result in context: ~30 seconds for `install.sh`, ~30 seconds for the OTP exchange, ~30 seconds for funding (browser detour), ~60 seconds for the workflow itself, ~20 seconds for the polling cycle to converge. After that, every follow-up via `gecko_ask` is free, every paid extension via `extract-page` is ~$0.004, and the `builder` sub-agent treats `prd.acceptance_criteria` as the contract for when the V1 is done.

The user only handles two things directly: their email + OTP (~30 seconds), and Coinbase Onramp funding (~30 seconds). Everything else is orchestrated.
