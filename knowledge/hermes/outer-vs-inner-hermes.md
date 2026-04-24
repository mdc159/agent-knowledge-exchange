# Outer vs Inner Hermes

Use two Hermes layers with different authority boundaries.

## Outer Hermes

- host-native
- independent of Paperclip
- carries long-horizon operator memory
- can supervise company creation and node operations
- should persist across company lifecycles

## Inner Hermes

- used through Paperclip adapters
- scoped to a specific company
- should use company-local runtime homes
- should not inherit outer Hermes memory by accident

## Rule

Paperclip owns company state.

Outer Hermes may supervise or initialize companies, but company-state mutation
should flow through Paperclip rather than around it.
