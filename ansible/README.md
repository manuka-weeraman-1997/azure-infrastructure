# Ansible against Azure VMs

## What it does
Same role (`roles/app`, reused from [`aws-infrastructure/ansible`](https://github.com/manuka-weeraman-1997/aws-infrastructure/tree/main/ansible)) — the only thing that changes between clouds is *how Ansible finds its targets*.

## Behaviour
- **Dynamic inventory** (`azure_rm.yml`): instead of a static list of IPs, the `azure_rm` plugin queries Azure directly for VMs in `app-resource-group` and groups them by tag (`tag_Role_app`) — so when the VMSS scales out, the next Ansible run automatically includes the new instances without any inventory file edits.
- **`auth_source: auto`**: picks up credentials the same way the Azure CLI/Terraform provider does (environment variables, CLI login, or managed identity), so no separate secret has to be managed just for Ansible.

## Why it's needed
Configuration management has to be cloud-agnostic at the task level (install packages, template config, manage the service) but cloud-aware at the inventory level (how do I even know what hosts exist right now). Separating those two concerns is what lets the same role run against both AWS and Azure fleets.
