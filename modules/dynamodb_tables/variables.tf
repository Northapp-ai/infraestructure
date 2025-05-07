variable "environment" {
  description = "Nombre del entorno (por ejemplo: dev)"
  type        = string
}

variable "tables" {
  description = "Lista de tablas DynamoDB con claves y atributos"
  type = list(object({
    name        = string
    hash_key    = string
    sort_key    = optional(string)
    attributes  = optional(list(object({
      name = string
      type = string # "S" | "N" | "B" | "BOOL" | "M" | "L"
    })))
  }))
}
