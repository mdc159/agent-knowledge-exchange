# Street Wisdom: Lawful Tijuana Social + Public Intel Sources

> Last Updated: May 2026  
> Owner: remote-worker / 1215 Dynamics knowledge base  
> Scope: public/open-source monitoring only; no fake accounts, login scraping, or bot evasion.

## TL;DR

- **Official sources first**: city, public safety, civil protection, water, border, weather, and airport data are higher-confidence than social chatter.
- **Social media is useful but legally fragile**: Facebook/Instagram should be monitored manually or via approved Meta APIs only. X/Twitter should use official API access only.
- **Human network beats scraping**: WhatsApp/Facebook groups can be valuable, but join and participate as a real person/business, not as an automation target.
- **Corroborate before escalating**: urgent claims need an official source or two credible independent sources.
- **Label uncertainty**: separate official alerts, media reports, public social posts, and unverified street chatter.

---

## Operating Rules for Agents

Agents may:

- Research public websites and official public feeds.
- Use RSS/Atom/API endpoints intentionally published for machine access.
- Use official platform APIs after credentials and permissions are configured.
- Summarize user-provided links, screenshots, exported posts, or manually collected notes.
- Maintain watchlists and query lists in this repository.

Agents must not:

- Create fake Facebook/Instagram/X personas.
- Automate browser activity behind login walls.
- Scrape Facebook groups, Instagram pages, private profiles, member lists, comments, or private communities.
- Rotate accounts/IPs or bypass rate limits, access controls, robots.txt, or platform restrictions.
- Treat social chatter as confirmed fact without corroboration.

---

## Compliance Notes

### Facebook / Meta

Meta is useful in Tijuana because many official pages and local groups post there first, but automated collection is restricted.

Use:

- Manual monitoring from a real human-administered account.
- A real 1215 Dynamics/remote-worker business presence if created transparently.
- Meta Graph API only where allowed.
- Page Public Content Access only after App Review and Business Verification if the use case qualifies.

Avoid:

- Bot accounts.
- Browser automation behind login.
- Scraping groups or public pages without permission.
- Collecting private user data, member lists, or comments at scale.

Reference:

- Meta Automated Data Collection Terms: https://www.facebook.com/legal/automated_data_collection_terms
- Page Public Content Access: https://developers.facebook.com/docs/features-reference/page-public-content-access/

### Third-Party Facebook Scraper Marketplaces / Apify

Apify offers maintained Facebook scraper actors, including:

- Facebook Groups Scraper: https://apify.com/apify/facebook-groups-scraper
- Facebook Posts Scraper: https://apify.com/apify/facebook-posts-scraper
- Facebook Pages Scraper: https://apify.com/apify/facebook-pages-scraper

These tools can extract public Facebook group/page/profile data and export structured datasets. However, their existence does **not** eliminate Meta policy risk for 1215 Dynamics.

Operational guidance:

- Treat Apify Facebook actors as **high policy-risk** unless Meta permission/API authorization is confirmed for the intended use.
- Do not use Apify to scrape Facebook groups, pages, comments, user profiles, or engagement data for routine monitoring without explicit review.
- Do not assume “public” equals “safe to automate.” Meta’s automated data terms still require express written permission or explicit authorization for automated collection from Meta products.
- If Apify is considered later, require a human compliance decision first and document: target URLs, data fields, purpose, retention period, legal basis, and whether personal data is collected.
- Prefer official Meta API access, manual monitoring, user-provided links/screenshots, newsletters, or non-Meta public sources.

Bottom line: Apify may be technically capable, but for this operation it should be a **review-required exception**, not the default monitoring path.

### X / Twitter

Use official X API tooling if automated reads/writes are needed. Do not scrape `x.com` pages through browser automation.

Use:

- Official API access through approved tooling such as `xurl`.
- Manual following/lists from a real account.
- Public links provided by humans.

Avoid:

- Cookie/session automation.
- Reverse-engineered APIs.
- Bulk follow/like/reply automation.
- Any engagement pattern that looks like spam.

Reference:

- X Developer Policy: https://docs.x.com/developer-terms/policy

---

## Source Categories

### 1. Official Municipal / Public Safety Sources

These are priority sources for confirmed alerts, emergency updates, city notices, inspections, and public-safety impacts.

- **Ayuntamiento de Tijuana**  
  URL: https://www.tijuana.gob.mx/  
  Use for: city announcements, municipal programs, permits, public notices.

- **Tijuana Emergencias**  
  URL: https://www.tijuana.gob.mx/emergencias/  
  Use for: emergency contacts, linked official emergency resources, civil protection references.

- **Protección Civil Tijuana — comunicados**  
  URL: https://proteccioncivil.tijuana.gob.mx/noticialistadoDependencia.aspx  
  Use for: weather risk, landslides, rain/flood advisories, inspections, event safety.

- **Protección Civil Tijuana — Facebook**  
  URL: https://www.facebook.com/dmpctj/  
  Monitoring method: manual or approved Meta API only.

- **Secretaría de Seguridad y Protección Ciudadana Municipal / Policía Tijuana**  
  Main site: https://policia.tijuana.gob.mx/  
  News: http://policia.tijuana.gob.mx/noticialistadoDependencia.aspx  
  Weekly bulletin archive: https://policia.tijuana.gob.mx/_enterate1.aspx  
  Facebook: https://www.facebook.com/SSPCM/  
  X: https://x.com/policiatijuana

- **Dirección de Bomberos Tijuana — Facebook**  
  URL: https://www.facebook.com/bomberostj/  
  Monitoring method: manual or approved Meta API only.  
  Note: informational page; do not use as emergency reporting channel.

### 2. Utilities / Infrastructure

- **CESPT — water service**  
  Main site: https://www.cespt.gob.mx/  
  Programmed closures: https://www.cespt.gob.mx/programa.aspx  
  Latest news: https://www.cespt.gob.mx/noticiascespt/noticiasultimas.aspx  
  Facebook: https://www.facebook.com/CesptOficial/  
  Use for: water cuts, sewer work, affected colonias, infrastructure repairs.

- **Gobierno de Baja California — Prensa**  
  URL: https://www.bajacalifornia.gob.mx/Prensa  
  Use for: state-level public safety, health, infrastructure, labor, economic, and policy announcements.

### 3. Border / Logistics / Mobility

These sources matter for cross-border operations, employees, visitors, delivery timing, and logistics.

- **CBP Border Wait Times API**  
  URL: https://bwt.cbp.gov/api/waittimes  
  Use for: official San Ysidro, Otay Mesa, Tecate waits; passenger, pedestrian, commercial, SENTRI/Ready lanes.

- **CBP Border Wait Times RSS builder**  
  URL: https://bwt.cbp.gov/customRss/New  
  Use for: low-friction alerting via RSS.

- **CBP San Ysidro page**  
  URL: https://bwt.cbp.gov/details/09250401/POV

- **CBP Otay Mesa passenger page**  
  URL: https://bwt.cbp.gov/details/09250601/POV

- **Tijuana Airport / GAP flight info**  
  URL: https://www.aeropuertosgap.com.mx/en/?Itemid=1267  
  Use for: airport disruption and flight status monitoring.

### 4. Weather / Earthquake / Environmental Sources

- **Servicio Meteorológico Nacional / CONAGUA**  
  URL: https://smn.conagua.gob.mx/es/  
  Use for: official weather forecasts, warnings, rainfall, heat, wind, storm advisories.

- **USGS earthquake map and feeds**  
  URL: https://earthquake.usgs.gov/earthquakes/map/  
  Use for: earthquake monitoring via public maps and feeds.

- **Servicio Sismológico Nacional — UNAM**  
  URL: http://www.ssn.unam.mx/english/seismicity/latest-earthquakes/  
  Use for: Mexico/Baja California seismic monitoring.

### 5. Local / Regional News

Use as secondary corroboration and early signal detection. Prefer RSS, newsletters, search alerts, GDELT, or manual review. If no feed exists, do not aggressively scrape.

- **ZETA Tijuana** — https://zetatijuana.com/
- **El Imparcial Tijuana** — https://www.elimparcial.com/tijuana/
- **El Sol de Tijuana** — https://www.elsoldetijuana.com.mx/
- **Agencia Fronteriza de Noticias / AFN** — https://www.afntijuana.info/
- **Cadena Noticias Regional** — https://cadenanoticias.com/regional/
- **Punto Norte** — https://puntonorte.info/
- **San Diego Red** — https://www.sandiegored.com/
- **KPBS Tijuana RSS** — https://www.kpbs.org/tags/tijuana.rss
- **Voice of San Diego** — https://voiceofsandiego.org/

Suggested query terms:

- `Tijuana bloqueo`
- `Tijuana cierre vial`
- `Tijuana incendio`
- `Tijuana CESPT`
- `Tijuana garita`
- `Tijuana seguridad`
- `Tijuana transporte público`
- `Tijuana lluvias`
- `Tijuana maquiladora`
- `Tijuana zona río`
- `Tijuana Otay`
- `Tijuana Playas`
- `Tijuana Centro`
- `Tijuana La Mesa`

### 6. Business Chambers / Economic Sources

Use for business climate, labor issues, regulation, chamber events, industrial logistics, and local lobbying priorities.

- **CANACO Tijuana**  
  Site: https://www.canacotijuana.com/  
  Blog: https://www.canacotijuana.com/blogs  
  Facebook: https://www.facebook.com/canacotj/

- **COPARMEX Tijuana**  
  Site: https://www.coparmextijuana.org/

- **Consejo de Desarrollo Económico de Tijuana / CDT**  
  Site: https://cdt.org.mx/  
  News: https://cdt.org.mx/noticias/  
  Facebook: https://www.facebook.com/CDTijuana/  
  Instagram: https://www.instagram.com/cdt.tijuana/  
  X: https://x.com/CDTijuana

- **Consejo Coordinador Empresarial Tijuana / CCE**  
  Site: https://www.ccetijuana.org/  
  Facebook: https://www.facebook.com/CCETijuana/  
  Instagram: https://www.instagram.com/cce.tijuana/

- **Index Zona Costa Baja California**  
  Site: https://www.indexzonacostabc.org.mx/  
  Facebook: https://www.facebook.com/IndexZonaCostaBC/  
  Use for: maquiladora/export/manufacturing conditions in Tijuana, Tecate, Ensenada, and Rosarito.

- **Industrial News BC**  
  Site: https://www.industrialnewsbc.com/  
  Use for: maquiladora, industrial parks, investment, manufacturing operations.

---

## Public Social Watchlist

These accounts/pages are candidates for **manual follow** or **official API monitoring only**.

- Protección Civil Tijuana — https://www.facebook.com/dmpctj/
- SSPCM Tijuana — https://www.facebook.com/SSPCM/
- Policía Tijuana X — https://x.com/policiatijuana
- Bomberos Tijuana — https://www.facebook.com/bomberostj/
- CESPT — https://www.facebook.com/CesptOficial/
- Ayuntamiento de Tijuana — https://www.facebook.com/gobtijuanamx/
- CDT Tijuana — https://www.facebook.com/CDTijuana/ and https://x.com/CDTijuana
- CCE Tijuana — https://www.facebook.com/CCETijuana/
- Index Zona Costa BC — https://www.facebook.com/IndexZonaCostaBC/

Recommended setup:

1. If a Facebook presence is needed, create a transparent human-administered business account/page, not a fake bot persona.
2. Follow official/public pages manually.
3. Let humans forward links, screenshots, or summaries to remote-worker for analysis.
4. If automation becomes necessary, pursue approved API access instead of browser scraping.

---

## Alert Taxonomy

Severity:

- `info`: routine business-relevant update.
- `watch`: possible disruption; monitor.
- `advisory`: likely localized operational impact.
- `urgent`: confirmed major disruption or safety risk.
- `critical`: immediate risk to people or core operations.

Categories:

- `public_safety`
- `weather`
- `earthquake`
- `water`
- `power`
- `border`
- `traffic_mobility`
- `business_regulation`
- `labor_economy`
- `industrial_logistics`
- `protests_blockades`
- `tourism_events`
- `neighborhood_alert`

Confidence labels:

- `official_confirmed`: official source confirms.
- `media_reported`: credible media reports, not yet official.
- `multi_source`: two or more independent credible sources.
- `social_unverified`: public social chatter only.
- `human_network_unverified`: trusted-contact tip but not independently confirmed.

---

## Daily Monitoring Playbook

1. Check official alerts:
   - Protección Civil Tijuana
   - Policía / SSPCM
   - CESPT
   - Gobierno BC Prensa
2. Check operational feeds:
   - CBP border wait times / RSS
   - SMN/CONAGUA weather
   - USGS/SSN seismic feeds
   - airport status if travel matters
3. Scan local/regional news queries.
4. Review manual social watchlist for official pages only.
5. Tag each item by category, severity, confidence, geography, and operational impact.
6. Escalate only when:
   - official confirmation exists, or
   - two credible sources agree, or
   - a trusted human source flags immediate risk and the uncertainty is clearly labeled.

---

## Incident Triage Checklist

For each incident candidate, capture:

- Source URL or human source note.
- Timestamp and timezone.
- Location / colonia / crossing / affected route.
- Category and severity.
- Confidence label.
- Operational impact for 1215 Dynamics.
- Recommended action.
- Follow-up check time.

Example:

```yaml
incident:
  title: "CESPT programmed water outage in Otay"
  source: "https://www.cespt.gob.mx/programa.aspx"
  timestamp_local: "2026-05-01T09:00:00-07:00"
  category: water
  severity: advisory
  confidence: official_confirmed
  geography: "Otay / affected colonias per CESPT notice"
  operational_impact: "Check whether office/shop site or employee homes are affected."
  recommended_action: "Notify affected team; confirm water storage if needed."
  follow_up: "Recheck CESPT notice in 4 hours."
```

---

## Street Reality Notes

- **Official = rules; street = reality**. Use both, but label them differently.
- **Relationships matter**. Local lawyers, accountants, realtors, gestores, chamber members, and vendors often hear real disruption before it hits formal channels.
- **Listen before asking** in WhatsApp/Facebook communities. Reputation matters.
- **Never outsource judgment to one source**. A single loud post can be bullshit, panic, politics, or clout-chasing.
- **Keep humans in the loop** for private groups, sensitive locations, rumors, crime, or anything that could hurt people if mishandled.

---

## Follow-Up Work

- Build a `source-catalog.yaml` with polling cadence, reliability, access method, and owner per source.
- Add an OPML file for RSS-capable sources.
- Create a daily Tijuana brief template.
- If X monitoring becomes useful, install/configure `xurl` with official X API credentials.
- If Meta monitoring becomes necessary, evaluate Meta App Review and Page Public Content Access instead of scraping.
