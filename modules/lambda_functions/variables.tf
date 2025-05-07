variable "lambdas" {
  description = "Lista de funciones Lambda a crear"
  type = list(object({
    name     = string
    filename = string
    handler  = string
    runtime  = string
    environment = optional(map(string))

  }))
}
