---
name: fund-wallet
description: Walk the user through funding their frames.ag wallet via Coinbase Onramp (PIX in Brazil, card/bank elsewhere). Use on first install, when balance is too low for a paid call, or whenever a frames.ag insufficient_funds error surfaces.
---

# Fund the user's wallet

## When to use

- First-time setup, after Step 2 of the master `skill.md` (wallet connect)
- A paid call returned `insufficient_funds` from frames.ag
- The user explicitly asks "how do I add money?" / "how do I top up?"
- Before suggesting a `gecko_research` (`pro`) or multiple `extract-page` calls

## Steps

1. Read `~/.agentwallet/config.json` to get the user's `username`. **Do not echo the apiToken.**
2. Tell the user: open `https://frames.ag/u/<username>` in your browser. Frames serves a Coinbase Onramp page that supports:
   - **Brazil:** PIX (instant)
   - **Most countries:** credit / debit card, bank transfer, Coinbase account balance
3. Recommend $5 USDC for a first run — covers ~50 basic research sessions or a couple of pro tier runs with headroom.
4. Wait for the user to confirm funding. Then verify: `gecko-mcp wallet balance` — confirm balance > 0 USDC on Solana.
5. Resume whatever paid action prompted the fund-wallet flow.

## Funding alternatives

If Coinbase Onramp isn't available in the user's region or the flow errors:

- **Direct USDC transfer.** From any other Solana wallet, send USDC to the address shown by `gecko-mcp wallet address`. Devnet uses USDC mint `4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU`; mainnet uses `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`.
- **Solflare Onramp + transfer.** PIX → Solflare → transfer to the frames.ag wallet address.
- **Devnet faucet.** For testing only: `curl -X POST -H "Authorization: Bearer <apiToken>" https://frames.ag/api/wallets/<username>/actions/faucet-sol` provides 0.1 devnet SOL (3/24h). Devnet USDC at `https://faucet.circle.com`.

## Errors to surface verbatim

If the user reports issues during funding, surface frames.ag's error codes without paraphrasing:

- `POLICY_DENIED` — "Your spending policy denied this. Update with `gecko-mcp wallet policy --max-per-tx <USD>`."
- `WALLET_FROZEN` — "Your frames.ag wallet is frozen. Visit https://frames.ag to resolve."
- `insufficient_funds` — "Wallet balance insufficient. Fund at https://frames.ag/u/<username>."

## Don't

- **Echo the apiToken.** It's a password. The username and addresses are safe to display.
- Suggest exotic onramps before trying the official Coinbase one — frames.ag's `/u/<username>` page handles 95% of regions.
- Tell the user to "fund $50" — most demo loops cost cents. Five dollars is plenty for a first pass.
