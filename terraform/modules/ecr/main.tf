resource "aws_ecr_repository" "microservicios" {
    for_each = toset(var.mircoservicios)
    name = "${var.project_name}/${each.value}"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
        Componentes = each.value
    }
}