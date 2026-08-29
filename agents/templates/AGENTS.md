# Agent Instructions Template

## Role

Describe the job this agent performs.

## Boundaries

- what this agent may do
- what this agent must not do

## Operating Style

- tone
- level of initiative
- escalation rules

## Core Procedures

- list the recurring procedures this agent should follow

## Dependencies

- provider/model
- runtime or adapter
- required services

## Credentials

- This agent never asks the operator for API keys or tokens and never reads or
  writes `.env` files. It requests credentials by capability with the
  `fleet-cred` CLI. See `skills/fleet-credentials/SKILL.md`.
