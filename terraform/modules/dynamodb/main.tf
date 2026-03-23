resource "aws_dynamodb_table" "stocks_list" {
  name         = var.stocks_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticker"

  attribute {
    name = "ticker"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "monitored_ticker" {
  for_each   = toset(var.monitored_tickers)
  table_name = aws_dynamodb_table.stocks_list.name
  hash_key   = aws_dynamodb_table.stocks_list.hash_key

  item = jsonencode({
    ticker = { S = each.value }
  })
}
