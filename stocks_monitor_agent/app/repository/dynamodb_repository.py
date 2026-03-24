import logging

import boto3

from app.model.stock_data import MonitoredStock

logger = logging.getLogger(__name__)


def fetch_monitored_stocks(dynamodb_client, stocks_table_name: str) -> list[MonitoredStock]:
    """Fetches the list of monitored stocks from DynamoDB."""
    response = dynamodb_client.scan(TableName=stocks_table_name)
    stocks = []
    for item in response.get("Items", []):
        ticker_attr = item.get("ticker")
        if ticker_attr:
            ticker = ticker_attr.get("S")
            if ticker:
                stocks.append(MonitoredStock(ticker=ticker))
    logger.info("Fetched %d monitored stocks from DynamoDB", len(stocks))
    return stocks
