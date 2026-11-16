# =============================================================================
# providers.tf
# Configuración de Terraform y de los providers (plugins) que usamos.
# =============================================================================

terraform {
  # Versiones de Terraform permitidas para este código.
  # Tu versión (1.17.2) cumple: es >= 1.9.0 y < 2.0.0
  required_version = ">= 1.9.0, < 2.0.0"

  # Providers necesarios. "terraform init" los descarga en la carpeta .terraform/
  required_providers {
    # Provider oficial de Azure (habla con Azure Resource Manager)
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20" # cualquier 4.x a partir de 4.20, nunca la 5.x
    }

    # Provider para generar valores aleatorios (lo usamos para el nombre único)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Configuración del provider de Azure.
provider "azurerm" {
  # Bloque obligatorio, aunque esté vacío. Sirve para ajustar comportamientos
  # avanzados del provider (no los necesitamos).
  features {}

  # No registrar automáticamente los servicios de Azure en la suscripción.
  # La identidad de GitHub Actions solo tiene permisos sobre un RG y fallaría.
  # (Microsoft.Storage ya quedó registrado en la Fase 1.)
  resource_provider_registrations = "none"

  # NO escribimos aquí el subscription_id (no queremos IDs en Git).
  # El provider lo lee de la variable de entorno ARM_SUBSCRIPTION_ID.
  # Autenticación:
  #   - En tu PC: tu sesión de "az login".
  #   - En GitHub Actions: OIDC (variables ARM_USE_OIDC, ARM_CLIENT_ID, ARM_TENANT_ID).
}
