# =============================================================================
# variables.tf
# Parámetros de entrada del proyecto. Se usan en el código como var.<nombre>.
# Los valores se dan en terraform.tfvars (ver terraform.tfvars.example).
# =============================================================================

# Obligatoria (sin default): forma parte del nombre de todos los recursos
variable "prefijo" {
  description = "Prefijo de los nombres de los recursos. Solo minúsculas y números, de 3 a 10 caracteres (ej: portfolio)."
  type        = string

  validation {
    # regex() falla si no hay coincidencia; can() convierte ese fallo en false
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefijo))
    error_message = "El prefijo debe tener de 3 a 10 caracteres, solo minúsculas y números (sin guiones ni mayúsculas), porque se usa en el nombre de la Storage Account."
  }
}

# Obligatoria (sin default): así siempre decides conscientemente el entorno
variable "entorno" {
  description = "Entorno de despliegue: dev, test o prod."
  type        = string

  validation {
    # contains(lista, valor) devuelve true si el valor está en la lista
    condition     = contains(["dev", "test", "prod"], var.entorno)
    error_message = "El entorno debe ser \"dev\", \"test\" o \"prod\"."
  }
}

variable "ubicacion" {
  description = "Región de Azure donde se crean los recursos."
  type        = string
  default     = "spaincentral"

  validation {
    condition     = contains(["spaincentral", "westeurope", "northeurope"], var.ubicacion)
    error_message = "Regiones permitidas: spaincentral, westeurope o northeurope."
  }
}

variable "tipo_replicacion" {
  description = "Replicación de la Storage Account. LRS es la más barata. OJO: cambiar a ZRS fuerza el reemplazo (borra la cuenta y sus datos) y GRS/ZRS cuestan más."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "ZRS"], var.tipo_replicacion)
    error_message = "El tipo de replicación debe ser LRS, GRS o ZRS."
  }
}

variable "etiquetas_extra" {
  description = "Etiquetas adicionales para todos los recursos (ej: { propietario = \"tu-nombre\" }). No pueden sobrescribir las etiquetas comunes."
  type        = map(string)
  default     = {}
}
