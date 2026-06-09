locals {
    microservicios = [
        "admin",
        "ui",
        "cart",
        "catalog",
        "checkout",
        "orders"
    ]
}

resource "aws_ecr_repository" "microservicios" {
    for_each = toset(local.microservicios)
    name = "mi-proyecto/${each.value}
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
        Componentes = each.value
    }
}