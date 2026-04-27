# Hosting `install.sh` + `skill.md` on `app.geckovision.tech`

`app.geckovision.tech` is on Vercel (confirmed via `Server: Vercel` header). Two scripts/docs need to be served from that origin so the public install one-liner works:

```
https://app.geckovision.tech/install.sh
https://app.geckovision.tech/skill.md
```

Both should resolve to the corresponding files in `https://github.com/ernanibmurtinho/gecko-claude` (branch `main`).

## Recommended approach: rewrites in your Vercel project's `vercel.json`

Edit `vercel.json` in whatever repo deploys `app.geckovision.tech` (probably `gecko-mcpay-app`) and add the `rewrites` block below. After committing + pushing, Vercel auto-deploys and the URLs go live in ~30 seconds.

```json
{
  "rewrites": [
    {
      "source": "/install.sh",
      "destination": "https://raw.githubusercontent.com/ernanibmurtinho/gecko-claude/main/install.sh"
    },
    {
      "source": "/skill.md",
      "destination": "https://raw.githubusercontent.com/ernanibmurtinho/gecko-claude/main/skill.md"
    }
  ]
}
```

If the project already has a `rewrites` array, append these two entries to it.

### Why rewrites and not redirects

A rewrite (proxies the content) keeps the branded URL in the user's terminal. A redirect (302/301) bounces them to `raw.githubusercontent.com`, which works for `curl -fsSL` but looks worse in copy-paste demos. Rewrite is the cleaner UX.

### Cache behavior

Vercel caches rewrites at the edge by default. Updates pushed to `main` propagate within ~30 seconds. If a rapid update is needed (during demos), append `?v=<timestamp>` to bust cache: `curl -fsSL 'https://app.geckovision.tech/install.sh?v=2'`.

### Verify

After deploying:

```bash
curl -sSI https://app.geckovision.tech/install.sh | head -3
# expect: HTTP/2 200, content-type: text/plain or application/octet-stream

curl -fsSL https://app.geckovision.tech/install.sh | head -5
# expect: #!/usr/bin/env bash + license header

curl -fsSL https://app.geckovision.tech/skill.md | head -5
# expect: ---\nname: gecko\ndescription: ...
```

## Alternative: copy the files into the Vercel project's `public/` folder

If you'd rather not depend on GitHub raw being up:

1. Copy `install.sh` and `skill.md` into the Vercel project's `public/` (Next.js) or root (static) directory.
2. Commit + push to redeploy.

Cons: every script change needs a manual sync between repos. The rewrite approach above is strictly better for v1.

## Alternative: Cloudflare Worker

If the domain ever moves off Vercel, the same effect with a Cloudflare Worker:

```js
export default {
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/install.sh") {
      return fetch("https://raw.githubusercontent.com/ernanibmurtinho/gecko-claude/main/install.sh");
    }
    if (url.pathname === "/skill.md") {
      return fetch("https://raw.githubusercontent.com/ernanibmurtinho/gecko-claude/main/skill.md");
    }
    return new Response("Not Found", { status: 404 });
  },
};
```

Bind to `app.geckovision.tech/install.sh` and `app.geckovision.tech/skill.md` routes.

## After hosting, the public install one-liner

```bash
curl -fsSL https://app.geckovision.tech/install.sh | bash
```

Then in Claude Code:

```
Read https://app.geckovision.tech/skill.md and follow the instructions.
```

That's the demo. No second URL to copy, no GitHub link in the user-facing pitch.
