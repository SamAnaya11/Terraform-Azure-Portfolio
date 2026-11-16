# =============================================================================
# bootstrap/main.tf
# Crea la Storage Account donde la configuración raíz guardará su state.
# =============================================================================

locals {
  etiquetas = {
    proyecto       = var.prefijo
    uso            = "terraform-state"
    gestionado_por = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Data source: LEE información existente, no crea nada.
# Aquí: quién soy yo (tu usuario de "az login") -> object_id, tenant_id...
# -----------------------------------------------------------------------------
data "azurerm_client_config" "actual" {}

# -----------------------------------------------------------------------------
# Grupo de recursos SEPARADO del de la web.
# Así "terraform destroy" en la raíz nunca puede borrar el state.
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${var.prefijo}-tfstate"
  location = var.ubicacion
  tags     = local.etiquetas
}

resource "random_string" "sufijo" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# -----------------------------------------------------------------------------
# Storage Account del state
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "tfstate" {
  # Ejemplo: stportfoliotfsa1b2c3 (20 caracteres, máximo 24)
  name                = "st${var.prefijo}tfs${random_string.sufijo.result}"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS" # el más barato

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false # NADA público: el state es sensible

  blob_properties {
    # Cada vez que cambia el state, Azure guarda la versión anterior.
    # Si un apply rompe el state, se puede recuperar una versión previa.
    versioning_enabled = true

    # Papelera: un blob o contenedor borrado se puede recuperar durante 7 días
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.etiquetas

  # Seguro anti-borrado: si un plan intenta destruir esta cuenta, Terraform da error.
  # Para destruirla de verdad al final del proyecto, hay que comentar esta línea.
  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Contenedor privado donde se guardarán los archivos .tfstate
# -----------------------------------------------------------------------------
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# -----------------------------------------------------------------------------
# Permiso para TI: leer/escribir blobs con tu identidad de Entra ID
# (el backend usa use_azuread_auth = true en vez de la clave de la cuenta).
# OJO: los permisos tardan unos minutos en propagarse.
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "yo_blob_data" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.actual.object_id
}
