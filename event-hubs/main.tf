# Example: Azure Event Hubs namespace (Kafka-protocol compatible).

resource "azurerm_eventhub_namespace" "this" {
  name                = var.namespace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  capacity            = var.throughput_units

  kafka_enabled = true

  network_rulesets {
    default_action = "Deny"
    virtual_network_rule {
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_eventhub" "events" {
  name                = "app-events"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = 3
}

resource "azurerm_eventhub_consumer_group" "app" {
  name                = "app-consumer-group"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.events.name
  resource_group_name = var.resource_group_name
}
