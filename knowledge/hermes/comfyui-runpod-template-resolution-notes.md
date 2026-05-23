# ComfyUI / RunPod Template Resolution Notes

Source project: `/home/example-user/projects/comfy`  
Primary local log: `/home/example-user/projects/comfy/docs/runpod-comfy-adventure-log.md`  
Started: 2026-05-16

## Summary

RunPod deploy URLs are not Docker image names. A URL like:

```text
https://console.runpod.io/deploy?template=x4px1sy09w
```

must be resolved through template metadata before any useful `docker pull` can happen. Public HTML/JS reconnaissance may reveal API structure, but private/community template metadata generally requires a RunPod bearer token.

## Reusable procedure

```text
deploy URL -> template id -> authenticated metadata -> image name -> registry pull -> image inspect -> derivative build/run
```

Avoid:

```text
deploy URL -> guessed image -> mutate known-good local container
```

## Credential separation

- `RUNPOD_API_KEY`: needed to resolve RunPod template metadata.
- Docker Hub / registry token: useful only after the image name is known and only for the registry/account it belongs to.
- Docker Desktop credentials and Docker Build Cloud builders are separate local/client concerns.

Do not print tokens. Record only presence, env var name, safe shape, and non-reversible checksum prefixes when needed.

## Local baseline worth preserving

Current working ComfyUI baseline from the WSL project:

| Field | Value |
|---|---|
| Container | `comfy-runpod-local` |
| Image | `example-user/comfy-runpod:local` |
| Endpoint | `http://127.0.0.1:8189` |
| Port mapping | `8189 -> 8188` |
| ComfyUI | `0.20.1` |
| Python | `3.12.3` |
| PyTorch | `2.11.0+cu128` |
| GPU | RTX 4070 Laptop, ~8 GB VRAM |
| Models | checkpoints `90`, loras `294`, vae `15` |

Rule: preserve this container as a reference; compare new images against it rather than overwriting it.

## Known RunPod behavior from this pass

- `GET https://rest.runpod.io/v1/templates/x4px1sy09w` returned `401` without a RunPod bearer token.
- The console deploy page is a client shell and did not expose `imageName` directly.
- Public GraphQL can reveal some official templates, but guessed direct filters for this template id failed validation.
- The stable documented path is the REST template endpoint with auth and include flags.

Template metadata fetch pattern:

```bash
curl -sS \
  -H "Authorization: Bearer [REDACTED]" \
  "https://rest.runpod.io/v1/templates/${TEMPLATE_ID}?includePublicTemplates=true&includeRunpodTemplates=true&includeEndpointBoundTemplates=true"
```

Record safe fields only: template name/id, image name, ports, mount paths, disk/volume sizes, env keys, command/entrypoint, and GPU assumptions.

## Why this matters

This is a general agent-control lesson: cloud templates often hide operational truth behind metadata APIs. Good agents should first map the indirection layer, then act. That makes the workflow shareable and reversible instead of a one-off terminal adventure.
