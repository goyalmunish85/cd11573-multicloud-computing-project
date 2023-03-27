data "azurerm_resource_group" "udacity" {
  name     = "Regroup_1g6ZBP8NzpCg"
}

resource "azurerm_container_group" "udacity" {
  name                = "udacity-continst"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  ip_address_type     = "Public"
  dns_name_label      = "udacity-munishgoyal-azure"
  os_type             = "Linux"

  container {
    name   = "azure-container-app"
    image  = "docker.io/tscotto5/azure_app:1.0"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "AWS_S3_BUCKET"       = "udacity-munishgoyal-aws-s3-bucket",
      "AWS_DYNAMO_INSTANCE" = "udacity-munishgoyal-aws-dynamodb"
    }
    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
  tags = {
    environment = "udacity"
  }
}

####### Your Additions Will Start Here ######

resource "azurerm_sql_server" "udacity" {
  name                         = "udacity-munishgoyal-azure-sql"
  resource_group_name          = azurerm_resource_group.udacity.name
  location                     = azurerm_resource_group.udacity.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  tags = {
    environment = "production"
  }
}

resource "azurerm_app_service" "udacity" {
  name                = "udacity-munishgoyal-azure-dotnet-app"
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  app_service_plan_id = azurerm_app_service_plan.udacity.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}