resource "aws_dynamodb_table" "this" {
  for_each = { for tbl in var.tables : tbl.name => tbl }

  name         = each.value.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = each.value.hash_key
  range_key    = each.value.sort_key != null ? each.value.sort_key : null

  dynamic "attribute" {
    for_each = concat(
      [
        { name = each.value.hash_key, type = "S" }
      ],
      each.value.sort_key != null ? [{ name = each.value.sort_key, type = "S" }] : [],
      each.value.attributes != null ? each.value.attributes : []
    )
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  tags = {
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false
  }
}
