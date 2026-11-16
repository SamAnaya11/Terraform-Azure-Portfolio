# =============================================================================
# bootstrap/variables.tf
# Todas tienen default: bootstrap no necesita terraform.tfvars.
# =============================================================================

variable "prefijo" {
  description = "Prefijo de los nombres de los recursos. Solo minúsculas y números, de 3 a 10 caracteres."
  type        = string
  default     = "portfolio"

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefijo))
    error_message = "El prefijo debe tener de 3 a 10 caracteres, solo minúsculas y números."
  }
}

variable "ubicacion" {
  description = "Región de Azure donde se crea la Storage del state."
  type        = string
  default     = "spaincentral"

  validation {
    condition     = contains(["spaincentral", "westeurope", "northeurope"], var.ubicacion)
    error_message = "Regiones permitidas: spaincentral, westeurope o northeurope."
  }
}

# -----------------------------------------------------------------------------
# Fase 4: GitHub Actions (OIDC)
# -----------------------------------------------------------------------------

variable "entorno_web" {
  description = "Entorno de la web a la que GitHub tendrá acceso (forma el nombre rg-<prefijo>-<entorno_web>)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.entorno_web)
    error_message = "El entorno debe ser \"dev\", \"test\" o \"prod\"."
  }
}

variable "github_subject_prefijo" {
  # Formato clásico:     repo:<usuario>/<repo>
  # Con IDs inmutables:  repo:<usuario>@<id>/<repo>@<id>
  # Si no coincide, GitHub Actions falla con AADSTS700213 y el error muestra el subject real: cópialo aquí.
  # Valores usados: usuario SamAnaya11 = ID 200885290, repo Terraform-Azure-Portfolio = ID 1460302292
  description = "Inicio del subject de los tokens OIDC de GitHub, sin la parte :environment:... (ver comentario)."
  type        = string
  default     = "repo:SamAnaya11@200885290/Terraform-Azure-Portfolio@1460302292"

  validation {
    condition     = startswith(var.github_subject_prefijo, "repo:") && !endswith(var.github_subject_prefijo, ":")
    error_message = "Debe empezar por \"repo:\" y no terminar en \":\" (la parte :environment:... se añade sola)."
  }
}
