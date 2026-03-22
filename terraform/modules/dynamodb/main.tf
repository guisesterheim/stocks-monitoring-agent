resource "aws_dynamodb_table" "stocks_list" {
  name         = var.stocks_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticker"

  attribute {
    name = "ticker"
    type = "S"
  }
}
