# Azure Infrastructure

Azure counterparts to the same platform engineering patterns as [`aws-infrastructure`](https://github.com/manuka-weeraman-1997/aws-infrastructure): elastic compute, configuration management, managed streaming, and traffic distribution — implemented with Azure-native services.

| Component | What it is | AWS equivalent |
|---|---|---|
| [`vmss/`](vmss) | Virtual Machine Scale Set | Auto Scaling Group |
| [`ansible/`](ansible) | Ansible playbook targeting Azure VMs | Same tool, same role |
| [`event-hubs/`](event-hubs) | Azure Event Hubs (Kafka-compatible) | MSK |
| [`application-gateway/`](application-gateway) | Application Gateway | Application Load Balancer |

Author: Manuka Weeraman — Platform Engineer
