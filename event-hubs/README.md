# Azure Event Hubs

## What it does
A managed event streaming service that exposes a **Kafka-compatible protocol** (`kafka_enabled = true`) — existing Kafka producer/consumer code can point at Event Hubs with just a connection-string change, no code rewrite.

## Behaviour
- **Partitions** (`partition_count`): each partition is an independently ordered log — messages for the same key land in the same partition, so consumers can process in parallel across partitions while preserving per-key ordering.
- **Consumer groups**: `azurerm_eventhub_consumer_group` gives each independent consumer application its own read position/offset into the same event stream, so multiple services can process the same events at their own pace without interfering with each other.
- **Network rules** (`default_action = "Deny"` + `virtual_network_rule`): the namespace is unreachable from the public internet by default — only traffic from the named subnet is allowed in, the same private-network posture as the MSK example on the AWS side.
- **Message retention**: events stay available for replay for the configured number of days, so a consumer that was down can catch up instead of losing data.

## Why it's needed
This is the Azure-side equivalent of MSK: the event-driven backbone that lets services react to things happening elsewhere (a price update, an order, a config change) without polling. Using the Kafka protocol specifically means the producer/consumer code and tooling can be shared across the AWS and Azure deployments of the same system.

---

## Reference implementation: end-to-end streaming on Azure Event Hubs

![MSK vs Event Hubs data flow](https://raw.githubusercontent.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/main/docs/images/msk-vs-event-hubs.gif)

```text
Application -> Producer -> Network -> Streaming Platform -> Topic / Event Hub
            -> Partitions -> Consumer Group -> Consumer -> Downstream Application
```

The example system is a market-data pipeline: a producer publishes `market-events` keyed by `symbol`, the stream has four partitions, and the consumer group `search-service` reads with one consumer per partition. The producer, consumer, Terraform, diagrams and docs all describe this same flow.

The namespace in [`main.tf`](main.tf) above is the core pattern. The folders below extend it into a complete, runnable flow.

### What is in this folder

| Path | Purpose |
|---|---|
| [`main.tf`](main.tf), [`variables.tf`](variables.tf) | The original minimal Event Hubs example |
| [`azure/terraform/`](azure/terraform) | Fuller Terraform: resource group, namespace, event hub, consumer groups, optional Private Endpoint and Private DNS, Log Analytics, alerts |
| [`azure/README.md`](azure/README.md) | How to run the fuller Terraform and what it does not do |
| [`producer/`](producer/README.md) | Python producer (`KAFKA_PLATFORM=eventhubs`), partition key = `symbol` |
| [`consumer/`](consumer/README.md) | Python consumer in group `search-service`, manual offset commits, graceful shutdown |
| [`kafka/`](kafka/README.md) | Topic design (`market-events`, 4 partitions, 1 day retention) and client properties examples |
| [`examples/`](examples) | Event schema and sample events |
| [`diagrams/`](diagrams/architecture.md) | Mermaid diagrams: MSK, Event Hubs, side by side, migration |
| [`scripts/`](scripts) | `setup.sh`, `test-connectivity.sh`, `cleanup.sh` |

### Run it

```bash
bash scripts/setup.sh                 # venv and dependencies
export KAFKA_PLATFORM=eventhubs
# set KAFKA_BOOTSTRAP_SERVERS (the namespace endpoint) and EVENTHUBS_CONNECTION_STRING as described in producer/README.md
bash scripts/test-connectivity.sh
```

The Kafka endpoint needs the Standard tier or higher. Microsoft Entra ID is the preferred authentication where your clients support it. Keep connection strings in a secret store. Running Terraform creates billable resources, so read [`azure/README.md`](azure/README.md) first.

### Conceptual mapping to AWS

| Concept | Amazon MSK | Azure Event Hubs |
|---|---|---|
| Producer | Kafka Producer | Event Producer |
| Streaming platform | Amazon MSK | Event Hubs Namespace |
| Topic | Kafka Topic | Event Hub |
| Partition | Kafka Partition | Event Hubs Partition |
| Consumer group | Kafka Consumer Group | Event Hubs Consumer Group |
| Consumer | Kafka Consumer | Event Consumer |
| Monitoring | CloudWatch | Azure Monitor |

These are conceptual mappings, not exact 1:1 equivalents. Amazon MSK is managed Apache Kafka. Azure Event Hubs is a managed event streaming service that exposes a Kafka-compatible endpoint, so topics are event hubs and several Kafka internals (replication, ISR) are managed by the service instead of exposed. See the [compatibility matrix](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/migration/compatibility-matrix.md).

The AWS counterpart is [`aws-infrastructure/msk`](https://github.com/manuka-weeraman-1997/aws-infrastructure/tree/main/msk).

### Deeper documentation (hub repository)

| Topic | Link |
|---|---|
| Architecture | [architecture.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/architecture.md) |
| End-to-end data flow | [data-flow.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/data-flow.md) |
| Amazon MSK | [msk.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/msk.md) |
| Azure Event Hubs | [azure-event-hubs.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/azure-event-hubs.md) |
| Comparison | [comparison.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/comparison.md) |
| Security | [security.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/security.md) |
| Networking | [networking.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/networking.md) |
| Observability | [observability.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/observability.md) |
| Migration guide | [kafka-to-event-hubs.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/migration/kafka-to-event-hubs.md) |
| Compatibility matrix | [compatibility-matrix.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/migration/compatibility-matrix.md) |
| Production checklist | [production-checklist.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/production-checklist.md) |
| Cost considerations | [cost-considerations.md](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs/blob/main/docs/cost-considerations.md) |
| Medium article | [Amazon MSK vs Azure Event Hubs: Same Event Flow, Different Engines](https://medium.com/@manukaweeraman/amazon-msk-vs-azure-event-hubs-same-event-flow-different-engines-46dcf08bd828) |

Everything is also in one place in [`msk-vs-azure-event-hubs`](https://github.com/manuka-weeraman-1997/msk-vs-azure-event-hubs).
