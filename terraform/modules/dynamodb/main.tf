resource "aws_dynamodb_table" "stocks_list" {
  name         = var.stocks_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticker"

  attribute {
    name = "ticker"
    type = "S"
  }
}

resource "aws_dynamodb_table" "stock_prices_history" {
  name         = var.prices_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticker"
  range_key    = "date"

  attribute {
    name = "ticker"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
