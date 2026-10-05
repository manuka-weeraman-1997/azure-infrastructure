# Azure Infrastructure

Azure counterparts to the same platform engineering patterns as [`aws-infrastructure`](https://github.com/manuka-weeraman-1997/aws-infrastructure): elastic compute, configuration management, managed streaming, and traffic distribution — implemented with Azure-native services.

| Component | What it is | AWS equivalent |
|---|---|---|
| [`vmss/`](vmss) | Virtual Machine Scale Set | Auto Scaling Group |
| [`ansible/`](ansible) | Ansible playbook targeting Azure VMs | Same tool, same role |
| [`event-hubs/`](event-hubs) | Azure Event Hubs (Kafka-compatible) | MSK |
| [`application-gateway/`](application-gateway) | Application Gateway | Application Load Balancer |

For a full streaming walkthrough, see [`event-hubs/`](event-hubs) (Python producer and consumer, Terraform, diagrams) and the cross-cloud write-up [`msk-vs-azure-event-hubs`](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs): Amazon MSK compared with Azure Event Hubs, with a migration guide and compatibility matrix.

Author: Manuka Weeraman — Platform Engineer
