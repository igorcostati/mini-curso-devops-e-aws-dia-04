resource "aws_ecr_repository" "this" {
  count = length(var.ecr_repository)

  name                 = var.ecr_repository[count.index].name
  image_tag_mutability = var.ecr_repository[count.index].image_tag_mutability
  force_delete         = true
}