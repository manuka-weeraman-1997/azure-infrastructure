# Example: Application Gateway (Layer-7) with a backend pool and health probe.

resource "azurerm_public_ip" "agw" {
  name                = "agw-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app" {
  name                = "app-agw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 4
  }

  gateway_ip_configuration {
    name      = "gwip"
    subnet_id = var.gateway_subnet_id
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  backend_address_pool {
    name = "app-backend-pool"
  }

  probe {
    name                = "app-probe"
    protocol            = "Http"
    path                = "/health"
    host                = "app.internal"
    interval            = 15
    timeout             = 10
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                  = "app-http-settings"
    port                  = 8080
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 30
    probe_name            = "app-probe"
  }

  http_listener {
    name                           = "app-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = var.ssl_certificate_name
  }

  ssl_certificate {
    name                = var.ssl_certificate_name
    key_vault_secret_id = var.key_vault_secret_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  request_routing_rule {
    name                       = "app-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "app-listener"
    backend_address_pool_name  = "app-backend-pool"
    backend_http_settings_name = "app-http-settings"
    priority                   = 100
  }
}
