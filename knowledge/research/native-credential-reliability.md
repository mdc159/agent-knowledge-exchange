# Native credential reliability: Infisical and 1Password

Research checked: 2026-09-07. Tracking: [GitHub issue #51](https://github.com/mdc159/agent-knowledge-exchange/issues/51).

## Question and conclusion

Which vendor capabilities can keep agents supplied with working credentials,
detect failures, and support recovery without inventing another credential system?

Reuse native delivery, caching, lifecycle management and health signals first.
These cover different failure modes. A readable vault record does not prove a
provider accepts the key, an accepted key does not prove paid inference is usable,
and a running process does not prove useful agent progress. Credential systems do
not by themselves provide an independent supervisor for a stopped agent or a
capability-aware model fallback chain.

## Capability map

| Native component | Reusable capability | Boundary |
| --- | --- | --- |
| [Infisical Agent](https://infisical.com/docs/integrations/platforms/infisical-agent) | Renews Infisical access tokens and dynamic leases; retries retrieval; renders secrets and can execute a command when they change. | Renewal of an Infisical token is not renewal of every external provider key or coding-plan session. Its documented persistent dynamic-lease caching requires Kubernetes. File rendering must fit the consuming application's credential policy. |
| [Infisical Proxy](https://infisical.com/docs/integrations/platforms/infisical-proxy) | Caches Infisical API responses, refreshes them and serves warm entries during upstream outages with optimistic eviction. | Cache keys include authentication token and request parameters. Cache is memory-only and clears on restart. It does not create missing cached entries during an outage or repair an expired external API key. |
| [Infisical Agent Proxy](https://infisical.com/docs/documentation/platform/agent-proxy/overview) | Applies credentials to outgoing API requests for agents that support the proxy transport. | Credential brokering does not establish model/provider failover. Test runtime HTTP-client compatibility; preserve the intended billing mode. |
| [PAM Credential Health](https://infisical.com/docs/documentation/platform/pam/product-reference/credential-health/overview) | Tests enrolled accounts against their real targets and distinguishes rejected credentials from unreachable targets. Supports SSH, databases, Windows and cloud accounts. | Supported target list is not a generic arbitrary-API-key checker. Scheduling ranges from one hour to 30 days, default 24 hours. A rejected credential pauses checks until recovery; detection alone does not repair it. |
| [Infisical webhooks](https://infisical.com/docs/documentation/platform/webhooks) | Reports secret changes and failed rotations to a receiving system. | Receiver must authenticate, scope and deduplicate events. Never execute an error message or payload as a command. Rotation-failure events should not cause blind repeated rotations. |
| [Monitoring](https://infisical.com/docs/documentation/platform/secrets-mgmt/monitoring) | Insights, change notifications and event subscriptions. | Secret activity is not agent process supervision or an inference readiness test. |
| [1Password Connect API](https://www.1password.dev/connect/api-reference) | Unattended vault-item access plus heartbeat, dependency health, metrics and API activity. | Health endpoints describe Connect itself. Updating a stored credential does not update its provider. |
| [1Password Events API](https://www.1password.dev/events-api/reference) | Account audit events, item usage and sign-in attempts. | Reporting interface, not credential renewal or agent recovery. |
| [1Password Agent Hooks](https://www.1password.dev/agent-hooks) | Currently documents validation of mounted Environment files before supported agent commands. | Not a general fleet watcher. |

The names matter: **Infisical Agent** handles lifecycle/rendering, **Infisical
Proxy** caches secret reads, and **Agent Proxy** brokers outbound credentials.
They are separate components. The inspected official CLI v0.43.129 also exposes
optional native event subscriptions for proxy invalidation with polling fallback;
those need explicit enrollment and were not part of the caching acceptance test.

## A first integration that can be proved without disrupting an application

1. Choose one enrolled host and checksum-pin the vendor proxy release. Keep its
   binary and service separate from existing clients.
2. Bind only to loopback. Use verified HTTPS from the proxy to the upstream vault.
   Application-to-proxy HTTP is confined to the same host; off-host access requires
   an appropriate authenticated encrypted transport.
3. Use the host's existing machine identity, without exporting values. Compare a
   real proxy response with the authorized direct response in memory.
4. Run a second test-only proxy behind a controllable loopback relay. Warm it, cut
   only that relay, allow native refresh/validation attempts to fail, and compare
   the cached result. Never take the production vault offline to simulate failure.
5. Verify an unauthenticated or invalid-token caller cannot read another token's
   cached records. Restart the test proxy while the relay is unavailable: a cold
   cache should fail. Restore the relay and verify recovery.
6. Check application health and process identity before and after. Distinguish a
   proven proxy endpoint from an application actually enrolled to consume it.

A single-host pilot of this pattern passed with official CLI v0.43.129: authorized
online equality, warm-cache outage continuity, invalid-token isolation, cold-cache
failure and subsequent recovery. Existing application health and process identity
were preserved. This is evidence for the pattern, not a claim that readers' hosts,
applications, accounts or native authentication flows have been enrolled.

Do not discard a working persistent encrypted offline cache based on a successful
warm-memory-cache test. A fresh authentication token may also have a cache miss:
the proxy's token-specific cache and the client's token lifecycle must be tested
together before changing normal application routing.

## Event integration and recovery boundaries

The inspected [upstream webhook sender](https://github.com/Infisical/infisical/blob/4a9722dfece259e033e2718c4c05a2c2ff810c74/backend/src/services/webhook/webhook-fns.ts)
computes HMAC-SHA256 over the serialized JSON body and sends
`x-infisical-signature: t=<milliseconds>;<hex digest>`. A receiver should verify
the exact request bytes, timestamp freshness and the signed body's timestamp;
do not assume another vendor's signature framing. Record event metadata only,
map an exact project/environment/path to a preconfigured action, and reconcile an
uncertain action before repeating it. These are integration recommendations,
not a claim that an event receiver was deployed in the caching pilot.

Keep native coding-plan authentication and API billing distinct. A speech API
key, a cloud infrastructure credential and a subscription-backed coding session
have different renewal paths. Provider credit exhaustion, insufficient scope,
rate limits and rejected authentication require different responses.

A separate independent watcher still needs to detect dead or stalled agents,
assign one recovery owner, preserve task state, and verify restoration. A local
model can assist that recovery, but the watcher itself should run without an LLM.

## Sources and review limits

Primary vendor links are attached to each capability above. The official tested
binary is from [Infisical CLI v0.43.129](https://github.com/Infisical/cli/releases/tag/v0.43.129).
The Linux x86_64 archive checksum was checked against that release's checksums.
Product documentation describes availability; it does not prove deployment,
entitlement, installed-server compatibility or successful provider use. No raw
logs, secrets, fleet inventory, access paths or operator-specific state belong in
this public note.
