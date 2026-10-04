# Application Gateway

## What it does
Azure's Layer-7 load balancer — the Azure equivalent of an AWS ALB. Terminates TLS, health-checks backends, and routes HTTP(S) traffic to a backend pool (in practice, a VMSS — see `vmss/`).

## Behaviour
- **Autoscaling** (`autoscale_configuration`): the gateway itself scales its own capacity (1-4 instances) based on load, so the load balancer doesn't become the bottleneck during a traffic spike.
- **Health probing**: `probe` polls `/health` every 15s and only routes to backends returning 200-399; after 3 consecutive failures a backend is pulled from rotation — the same contract the VMSS's own health probe relies on for replacing unhealthy instances.
- **TLS via Key Vault**: the certificate is referenced by `key_vault_secret_id` rather than uploaded directly, using a user-assigned managed identity to read it — certificate rotation happens in Key Vault without touching the gateway config.
- **Routing rule**: ties one listener to one backend pool via one set of HTTP settings — in a real deployment, multiple components each get their own listener/pool/rule sharing a single gateway, which is why this is usually built as one shared resource rather than one per service.

## Why it's needed
Same reason as the AWS ALB: a stable public entry point in front of a scaling, self-healing compute fleet, with TLS and health checking handled centrally instead of per-instance.
