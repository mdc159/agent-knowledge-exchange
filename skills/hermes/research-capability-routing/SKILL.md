---
name: research-capability-routing
description: Route agent research across search, extraction, crawlers, browser automation, X/Twitter APIs, and durable knowledge capture without leaking secrets.
version: 1.0.0
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [research, search, scraping, crawling, browser, x-twitter, source-grounded]
    category: research
---

# Research Capability Routing

Use this skill when an agent must choose among multiple research/search/scraping
backends or audit whether a research stack is configured and live.

## Core principle

Use layered "and, not or" routing:

```text
local knowledge -> web search/extract -> cited research -> source APIs/MCPs
-> structured crawler/scraper datasets -> browser automation -> heavy browser
fallback -> durable capture
```

Do not pick one universal backend. Start with the cheapest source family that
can answer correctly, then escalate for a named failure mode.

## Source-family routing

1. Existing/local knowledge
   - Use skills, notes, prior sessions, and local docs for reusable procedures.
   - Treat them as historical context, not proof of current external facts.

2. Public web discovery
   - Use general web search for candidate URLs.
   - Prefer official docs, primary sources, repositories, papers, and original
     posts over summaries.

3. Content extraction
   - Use extraction for known URLs, PDFs, docs, and articles.
   - If extraction is truncated or misses JS-rendered content, escalate instead
     of guessing.

4. Stronger cited web/news research
   - Use You.com-like research tools or comparable cited-answer APIs when broad
     synthesis needs citations, contradictions, or query expansion.
   - Use search/contents tools before deep research when possible.

5. Structured crawling/scraping
   - Use Firecrawl-like crawling when a known site needs map/crawl/extract.
   - Use Apify-like actors when a maintained scraper can produce structured
     rows from paginated or JS-heavy sources.
   - Always set row/page/cost caps when the tool supports them.

6. Browser automation
   - Use local browser, Browser Use, Playwright-like tools, or computer-use when
     the required information depends on rendering, clicks, filters, forms,
     screenshots, or console/DOM inspection.
   - Never type secrets, approve payments, or bypass private access controls
     unless a human explicitly scoped the action.

7. Heavy browser / anti-bot fallback
   - Use Camofox/Camoufox-style profiles only after ordinary extraction and
     browser automation fail for an in-scope public target.
   - Record why the lighter path was insufficient.

8. X/Twitter
   - Use broad `x_search`-style tools first for discourse and announcements.
   - Use official X API/MCP/xurl-style tools for raw structured search, counts,
     users, trends, news, timelines/bookmarks, or full-archive queries.
   - Use X docs tools before changing endpoint parameters.
   - Browser-authenticated X is a supervised fallback, not routine collection.

9. Durable capture
   - Promote reusable findings into a knowledge doc or skill.
   - Do not commit raw dumps, session databases, auth exports, logs, private
     endpoints, or secrets.

## Auditing configured vs live

For every capability, report both:

- Configured: plugin, MCP server, CLI, Docker image, env-var name, config stanza,
  or skill exists.
- Live verified: a read-only health/version/list/query call succeeded in this
  run.

Suggested evidence checks:

```bash
hermes profile list
hermes -p <profile> mcp list
hermes -p <profile> mcp test <server>
<cli> --version
docker ps
docker images
```

For API credentials, record environment variable NAMES only. Never print values.
For account endpoints, omit usernames, IDs, private URLs, and billing-sensitive
details unless the destination is explicitly private and approved.

## Capability matrix fields

Use this schema in audit reports:

| Field | Required detail |
|---|---|
| Category | Search, extract, crawl, browser, X, docs, local knowledge, etc. |
| Product/tool | Exact product or tool class |
| Status | absent, installed, configured, live-verified, blocked |
| Profiles | Sanitized profile roles exposing it |
| Access mode | managed tool, API, MCP, CLI, container, local service |
| Credential names | Env-var names only |
| Evidence | Sanitized path class, command, or public URL |
| Useful operations | What it should be used for |
| Limitations | Cost, auth, rendering, policy, freshness, scale |
| Routing tier | Where it sits in the ladder |

## Secret-safety checklist

Before publishing:

- Search changed files for secret-like strings.
- Check for private IPs, private network domains, local hostnames, account
  usernames, raw filesystem paths, `.env` content, auth JSON, cookies, and
  tokens.
- Run `git diff --check`.
- If the repo has hygiene/lint workflows, run their local equivalent.
- State what was configured vs live-verified and what was not tested.

## Pitfalls

- Do not infer a service is live from a Docker image or plugin alone.
- Do not infer a tool is exposed in a session from an env-var name alone.
- Do not use browser automation when extraction can read the page.
- Do not use scraper marketplaces for private or policy-sensitive social data
  without explicit human review.
- Do not publish machine-specific paths or private endpoints in reusable docs.
