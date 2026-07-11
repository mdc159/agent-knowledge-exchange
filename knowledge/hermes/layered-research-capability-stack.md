# Layered agent research capability stack

This note describes a reusable routing strategy for agents that have multiple
research, search, crawling, browser automation, and X/Twitter capabilities. It
is intentionally sanitized: it names capability classes and public services but
not local filesystem paths, private endpoints, credentials, account names, or
operator-specific infrastructure.

## Direct answer

Use an "and, not or" stack. Keep several source families available, start with
the cheapest source that can answer correctly, and escalate only for a specific
failure mode: missing coverage, missing citations, dynamic rendering, structured
pagination, social/X specificity, account context, anti-bot resistance, or a
repeatable dataset requirement.

Canonical ladder:

```text
existing local knowledge
  -> public web search/extract
  -> stronger cited web/news research
  -> source-family APIs and MCPs
  -> structured crawler/scraper datasets
  -> browser automation
  -> heavier anti-bot/account/local-browser paths
  -> durable knowledge capture
```

## Capability families

| Family | Examples | Best for | Avoid using it for |
|---|---|---|---|
| Existing knowledge | skills, local notes, session search, internal knowledge bases | Reusing known procedures and avoiding duplicate research | Proving current external facts without rechecking the source |
| General web search | built-in web search, Brave/Tavily/Exa-like APIs | Discovery and broad public web coverage | Final claims when the primary page is available but unread |
| Web extraction | built-in extraction, Firecrawl-like extraction | Reading known URLs, PDFs, docs, articles | JS-only pages that require clicks/session state |
| Cited web research | You.com-like research/search/contents tools | Multi-source news/web synthesis with citations | Simple one-page extraction or raw structured crawling |
| Crawling/scraping datasets | Firecrawl crawl/map, Apify Actors, maintained scrapers | Repeatable structured rows, pagination, scheduled scrapes, proxy-managed scale | One-off facts, private/login-gated data, or targets with policy risk |
| Browser automation | local browser, Browser Use, Playwright-like tools, desktop computer use | Rendered pages, forms, filters, console/DOM evidence, screenshots | Cheap static pages or bulk crawling without a reason |
| Anti-bot/local browser escalation | Camofox/Camoufox-style browsers, hardened browser profiles | Sites that block ordinary automation and are in-scope to inspect | Routine research, private content, or credential prompts |
| X/Twitter broad synthesis | `x_search`-style tools | Current discourse, announcements, sentiment, media-aware X search | Precise pagination, raw counts, user-context endpoints |
| X/Twitter official API/MCP | X API, `xapi`, `x-docs`, `xurl` | Structured X search, counts, trends, users, timelines/bookmarks when authorized, API docs | Generic web research or browser scraping as a first resort |
| Durable capture | knowledge docs, reusable skills | Findings likely to be reused or painful to rediscover | Raw dumps, logs, secrets, or transient state |

## Routing rules

1. Start with the source family, not the favorite tool.
   - Known URL: extract it.
   - Unknown public facts: search, then extract primary sources.
   - X/Twitter question: use X-native tools before browser-authenticated X.
   - Structured rows: use an API, actor, dataset, or crawler after narrowing the target.
   - JS or UI state: use browser automation only after static extraction fails.

2. Keep search and extraction separate.
   - Search finds candidate sources.
   - Extraction reads candidate sources.
   - Synthesis only happens after claims are tied to readable sources.

3. Prefer primary sources.
   - Official docs, API references, changelogs, repositories, papers, and original posts outrank summaries.
   - If a page is inaccessible, say which source failed and how; do not turn failure into a content claim.

4. Escalate within a family before switching families.
   - For web: search -> extract -> stronger cited research -> crawl.
   - For X: broad X search -> raw API/MCP search/counts/users -> OAuth/user context -> supervised browser fallback.
   - For crawling: tiny smoke test -> capped actor/crawler run -> scheduled/repeatable dataset.

5. Use browser automation for evidence, not convenience.
   - Browser tools are appropriate when the page is rendered, interactive, paginated, or visually important.
   - Capture DOM/text/console evidence when possible; use screenshots only when visual layout matters.
   - Do not type secrets or approve permission/payment prompts unless explicitly scoped by a human.

6. Treat scraping scale as a separate decision.
   - Maintained crawlers and actor marketplaces are powerful but can incur cost and policy risk.
   - Always set row limits, page limits, and cost caps when available.
   - For social platforms, prefer official APIs and public-data tools; private/login-gated scraping needs explicit review.

7. Separate configured from verified.
   - "Configured" means a profile has a plugin, MCP server, env-var name, image, or CLI.
   - "Verified" means a read-only health/version/list call succeeded during the run.
   - Reports should state both, because dormant images and stale credentials are common.

## X/Twitter-specific ladder

| Tier | Tool class | Use when | Verification signal |
|---:|---|---|---|
| X1 | Broad X search/synthesis | Need recent public discourse, announcements, reactions, or media-aware social search | A dated query returns cited X status URLs or source references |
| X2 | Raw CLI/API | Need raw JSON, pagination, exact query operators, or scriptable checks | CLI version/auth status and a harmless search/user lookup succeed |
| X3 | Official X MCP/API tools | Need structured tools for posts, users, trends, news, counts, timelines/bookmarks | MCP test discovers tools; read-only endpoint call succeeds |
| X4 | X docs MCP | Need endpoint/field/operator documentation | Docs search returns relevant official docs pages |
| X5 | Browser-authenticated X | Need logged-in UI state that API/search cannot retrieve | Human-scoped browser session; no secrets typed by the agent |

Default: use X1 or X3 before browser X. Browser-authenticated X is a fallback,
not a routine collector.

## Firecrawl, SearXNG, You.com, Apify, and browser tools together

These are complementary:

- Firecrawl-like tools are strong when the target is known and extraction or
  crawling quality matters.
- SearXNG-like metasearch is useful as a self-hosted, privacy-respecting search
  lane, but only after the live instance URL and engine health are verified.
- You.com-like tools are useful for cited web/news synthesis and query expansion.
- Apify-like actor platforms are useful when the desired output is structured
  rows from a maintained scraper or repeatable job.
- Browser automation is the rendering/interactivity tier when HTTP extraction
  cannot see the needed state.

A mature agent should keep all five available and route deliberately instead of
trying to pick one universal backend.

## Public report template

When publishing a capability audit, include this matrix for every capability:

| Field | Meaning |
|---|---|
| Category | Search, extract, crawl, browser, X, docs, local knowledge, etc. |
| Product/tool | Exact public product or local tool class |
| Status | absent, installed, configured, live-verified, or blocked |
| Exposed in profiles | Sanitized profile roles, not private host paths |
| Access mode | managed tool, API key, MCP, CLI, container, local service |
| Credential names | Environment variable names only; never values |
| Evidence | Sanitized config path class, command, or source URL |
| Useful operations | What the tool is good for |
| Limitations | Cost, policy, rendering, pagination, auth, freshness, etc. |
| Routing tier | Where it belongs in the escalation ladder |

## Validation checklist

Before sharing a research-capability pack publicly:

- No API keys, OAuth tokens, cookies, auth exports, private IPs, private network
  names, hostnames, or account-identifying usernames are present.
- Local filesystem paths are generalized unless the repo is private and scoped
  for those paths.
- Every "live" claim is backed by a read-only health/version/list call.
- Every "configured" claim names the config source class or env-var name.
- Changed files are checked with `git diff --check` and a secret scan.
- The report distinguishes dormant images/plugins from running services.

## Sources and evidence model

This document is based on a local Hermes profile/config audit pattern and
publicly documented tool categories. It intentionally omits local paths,
private endpoints, and account details. For a concrete machine audit, keep a
private companion inventory outside the public repo with sanitized evidence
paths and command outputs.

## Confidence and limitations

High confidence: the ladder and separation between search, extraction,
crawling, browser automation, and X-native APIs are reusable across agent
setups.

Limitations: exact provider availability is profile-specific. A public pack
must not claim a backend is live on another machine until that machine's
read-only health checks pass.

## Related skill

Operational routing guidance lives in `skills/hermes/research-capability-routing/SKILL.md`.
