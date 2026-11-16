# =============================================================================
# bootstrap/providers.tf
# Configuración INDEPENDIENTE de la raíz: tiene su propio init, plan, apply y state.
# Su state se queda en LOCAL (bootstrap/terraform.tfstate), a propósito:
# es la solución al "huevo y la gallina" (ver README).
# =============================================================================

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    # Fase 4: provider de Entra ID (aplicaciones, service principals, credenciales).
    # Habla con Microsoft Graph, no con Azure Resource Manager.
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  # Sin bloque "backend": el state se guarda en local.
}

provider "azurerm" {
  features {}
  # El subscription_id se lee de la variable de entorno ARM_SUBSCRIPTION_ID
}

provider "azuread" {
  # Usa tu sesión de "az login" (con el scope de Microsoft Graph).
  # El tenant es el de tu sesión.
}
