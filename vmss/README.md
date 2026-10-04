# Virtual Machine Scale Set (VMSS)

## What it does
The Azure equivalent of an AWS Auto Scaling Group: a pool of identical VM instances, created from one model (`source_image_reference`), that scales and self-heals as a unit.

## Behaviour
- **Rolling upgrades**: `upgrade_mode = "Rolling"` plus `rolling_upgrade_policy` means a model change (new image version, new size) is rolled out in batches of 20% of instances at a time, pausing 30s between batches — capacity never drops below 80% during a rollout, and a bad rollout halts automatically if too many upgraded instances become unhealthy.
- **Health probes**: `health_probe_id` ties the VMSS to the Application Gateway's health probe (see `application-gateway/`) — the same probe that decides routing also decides whether an instance needs replacing.
- **Autoscaling**: `azurerm_monitor_autoscale_setting` watches average CPU and adds one instance at a time when it's above 60% for 5 minutes, with a 5-minute cooldown so it doesn't oscillate on short spikes.
- **Backend pool attachment**: the NIC's `application_gateway_backend_address_pool_ids` is what actually registers each instance with the gateway — instances join/leave the pool automatically as the scale set grows/shrinks.

## Why it's needed
Same reasoning as an ASG: fixed-size VM fleets either waste money at idle or fall over at peak. VMSS gives elastic, self-healing capacity as a first-class Azure resource instead of a fleet of hand-managed VMs.
