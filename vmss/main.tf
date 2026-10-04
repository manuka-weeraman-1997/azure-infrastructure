# Example: Linux Virtual Machine Scale Set with autoscale rules.

resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "app-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_size
  instances           = var.default_instances
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching               = "ReadWrite"
  }

  network_interface {
    name    = "app-nic"
    primary = true

    ip_configuration {
      name                                          = "internal"
      subnet_id                                     = var.subnet_id
      application_gateway_backend_address_pool_ids  = [var.backend_pool_id]
    }
  }

  upgrade_mode = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT30S"
  }

  health_probe_id = var.health_probe_id
}

resource "azurerm_monitor_autoscale_setting" "app" {
  name                = "app-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app.id

  profile {
    name = "default"

    capacity {
      default = var.default_instances
      minimum = var.min_instances
      maximum = var.max_instances
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 60
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
