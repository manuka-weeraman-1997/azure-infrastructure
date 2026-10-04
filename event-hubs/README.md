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
