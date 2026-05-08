[5/5/2026 2:49 PM] Donna S.: Baby, I ran the memory-system check. Short version: the memory stack is alive and mostly healthy, but there are two real improvement targets: memory pressure in Hermes’ built-in injected memory, and identity fragmentation inside Honcho. There’s also a recall-quality caveat around fresh exact facts.

Executive status

Overall: functioning, but not optimal.

- Hermes memory provider: honcho
- Honcho API: reachable at http://127.0.0.1:18000
- Honcho workspace: donna
- AI peer: donna
- Configured user peer: miguel
- Recall mode: hybrid
- Write frequency: async
- Queue: drained successfully
- Embedding model: text-embedding-3-small
- Deriver/summary model: gpt-4o-mini
- Dialectic low/high/max/minimal: gpt-4o-mini
- Dialectic medium: o4-mini with low reasoning effort
- Dreamer/consolidation: disabled
- Storage: raw messages and embeddings are being written

What is healthy

1. Hermes sees Honcho correctly

hermes memory status says:

- Built-in memory active
- Provider: honcho
- Honcho plugin installed and available

hermes honcho status says:

- Enabled: true
- Workspace: donna
- AI peer: donna
- User peer: miguel
- Recall mode: hybrid
- Connection: OK

2. Honcho services are running

Containers are up:

- honcho-api-1
- honcho-deriver-1
- honcho-database-1
- honcho-redis-1

API is responding:

- OpenAPI version: 3.1.0
- Honcho API version: 3.0.6
- API bound to loopback: 127.0.0.1:18000

That is good. It is local/self-hosted as intended.

3. Queue/deriver is healthy

Queue status before smoke:

- Total work units: 20
- Completed: 20
- In progress: 0
- Pending: 0

After smoke write:

- Total work units: 22
- Completed: 22
- In progress: 0
- Pending: 0

So async memory processing is working and draining.

4. Embeddings are complete

Database counts:

- Messages: 616
- Message embeddings: 616
- Documents/observations: 10,425
- Document sync state: all synced

That is a very good sign. Raw message storage and embedding generation are not broken.

The o4-mini / reasoning-model status

You remembered correctly.

Current routing:

- Embeddings: text-embedding-3-small
- Deriver: gpt-4o-mini
- Summary: gpt-4o-mini
- Minimal dialectic: gpt-4o-mini
- Low dialectic: gpt-4o-mini
- High dialectic: gpt-4o-mini
- Max dialectic: gpt-4o-mini
- Medium dialectic: o4-mini, reasoning effort low

So the reasoning model was not swapped in globally. It is currently used only for medium-level dialectic, which is the safer staged experiment we discussed.

That’s sensible. I would not route all deriver/summary/memory formation through o4-mini yet.

The concerning findings

1. Hermes built-in memory is nearly full

The injected built-in memory/user-profile layer is under pressure.

Current approximate injected usage shown in-session:

- Memory notes: about 2,153 / 2,200 chars
- User profile: about 1,356 / 1,375 chars

That’s what I meant earlier by “memory full.”

This is not Honcho’s database being full. Honcho has plenty of room.

It means the compact Hermes memory block that gets injected into every session is nearly maxed out. That causes friction when saving new durable facts.

Risk: useful new operational facts may fail to save unless we prune or increase the limit.

2. Duplicate user identities exist in Honcho

This is the biggest architecture smell I found.

Honcho peers:

- miguel
- donna
- 8246962767

Message counts:

- donna: 287
- miguel: 260
- 8246962767: 69

Document/observation counts also exist for both miguel and 8246962767.

That means your memory is partially split between:

- the intended human peer: miguel
- the Telegram numeric peer: 8246962767

This can cause recall weirdness, because some observations about you are attached to miguel, while others are attached to 8246962767.
 (1/3)
[5/5/2026 2:49 PM] Donna S.: This is likely hurting performance more than the model choice.

3. Peer cards appear unavailable/empty

The honcho_profile tool returned:

 No profile facts available yet.

But honcho_context returned a rich representation with lots of observations.

So this local Honcho setup is not relying on peer cards in the way the tool expects, or the peer-card layer is not populated/supported in this self-hosted version.

Not fatal, but important:

- Representation/search/dialectic works
- Peer-card quick facts are empty

4. Fresh exact recall was imperfect

I ran a harmless smoke test:

 “Memory health smoke … Donna memory system check is read/write reachable.”

Raw DB confirmed:

- Message was stored
- Message was embedded
- Deriver queue processed it
- It created a document/observation

But the dialectic answer did not accurately recall the exact fact. It gave a stale/incorrect answer first, then after queue drain still missed the exact wording.

DB showed the derived document was weak:

 miguel mentioned 'Memory health smoke'.

So the storage path works, but the deriver compressed the message into a low-value observation, and dialectic didn’t reliably retrieve the precise raw message.

That suggests memory is good for general continuity, but exact fresh facts need better prompt/deriver/search tuning if we want high-fidelity operational recall.

My diagnosis

Healthy infrastructure

The containers, queue, embeddings, and API are healthy.

Main bottlenecks

1. Built-in memory injection is too full.
2. Honcho user identity is split between miguel and 8246962767.
3. Fresh exact recall is weaker than raw storage.
4. Dreamer/consolidation is disabled, so redundant/low-value observations may accumulate.
5. Dialectic context is fairly tight:
   - contextTokens: 1800
   - dialecticMaxChars: 700
   - base reasoning: low
   - cap: medium

Those limits are probably okay for speed, but not ideal for deep memory auditing.

Recommended adjustments

Priority 1 — Unify Honcho identity strategy

We should decide which peer is canonical.

I recommend:

- Canonical user peer: miguel
- Treat 8246962767 as Telegram transport identity, not memory identity

Then we should prevent future Telegram messages from creating/using 8246962767 as a separate remembered person.

I would not casually merge/delete DB rows live without a backup and a careful migration plan. But this is the biggest thing to fix.

Priority 2 — Prune or raise Hermes built-in memory limits

Current built-in memory is almost full.

Options:

- Prune duplicates from Hermes memory/user profile.
- Or raise config limits:
  - memory.memory_char_limit
  - memory.user_char_limit

I’d prefer a combination:

- prune stale duplicate notes,
- then modestly raise limits, maybe:
  - memory: 2200 → 3500
  - user profile: 1375 → 2200

But increasing injected memory also increases prompt bulk, so don’t make it enormous.

Priority 3 — Add a memory health cron/watchdog

Not a noisy pulse — a silent script-only health check.

It would check:

- Honcho API reachable
- queue pending/in-progress below threshold
- messages count == embeddings count
- recent write/read smoke processed
- no duplicate-peer growth beyond expected
- built-in memory pressure below threshold

It should alert only on failure.

Priority 4 — Improve exact recall testing

The smoke test showed that “stored and embedded” is not the same as “dialectic can recall exact detail.”

For operational memory, we should maintain two tests:

- Storage test: raw message exists + embedding exists + queue drains
- Recall test: dialectic/search can retrieve the intended fact

Right now storage passes. Exact recall is mixed.

Priority 5 — Consider enabling Dreamer/consolidation later

Current:

- DREAM_ENABLED=false

That means there is no active consolidation/dedup cleanup layer.
 (2/3)
[5/5/2026 2:49 PM] Donna S.: I would not enable it blindly. Dreamer can improve memory quality, but it can also delete/consolidate aggressively if configured wrong.

Safer staged approach:

1. Run dreamer/consolidation manually or in dry-run if available.
2. Inspect what it would delete/consolidate.
3. Only then enable scheduled dreamer.

My recommended next move

I would do this in order:

1. Back up Honcho DB / Hermes config.
2. Create a memory-health report script so this check is repeatable.
3. Fix canonical peer identity so Telegram routes to miguel, not 8246962767.
4. Clean compact Hermes memory/user profile and raise limits modestly.
5. Retest with exact recall smoke.
6. Only then consider changing models or enabling Dreamer.

Bottom line

Your memory system is not broken.

It is more like:

 The engine runs, the fuel lines are connected, but we’ve got some duplicate identity wiring and the dashboard warning light is taped over.

The most important performance improvement is probably not another model swap.  
It is canonicalizing your identity as miguel across Honcho/Hermes/Telegram and reducing compact-memory pressure. (3/3)
