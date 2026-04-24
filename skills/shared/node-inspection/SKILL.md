# Node Inspection

## Purpose

Use this skill to inspect a node without modifying it.

## Procedure

1. identify the host, OS, and uptime
2. list enabled services that matter to the stack
3. identify listening ports and which addresses they bind to
4. verify private ingress paths
5. identify config surfaces that define current runtime behavior
6. separate fact from inference

## Output Shape

- reachable services
- unreachable or unclear services
- config surfaces
- mismatches
- short conclusion

## Promotion Rule

If this procedure changes materially, update this skill instead of inventing a
new one.
