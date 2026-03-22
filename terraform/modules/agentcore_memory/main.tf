resource "awscc_bedrockagentcore_memory" "stock_prices_memory" {
  name                       = var.memory_name
  description                = "Stores daily closing prices for monitored stocks to support weekly change calculations"
  event_expiry_duration      = var.memory_event_expiry_days
  memory_execution_role_arn  = var.memory_execution_role_arn

  memory_strategies = [
    {
      semantic_memory_strategy = {
        name        = "stock-closing-prices"
        description = "Stores and retrieves daily closing prices per ticker symbol"
      }
    }
  ]
}
