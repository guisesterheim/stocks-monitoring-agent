import logging

import boto3

from app.model.config import AgentConfig
from app.model.stock_data import StockMarketData
from app.repository import browser_repository, dynamodb_repository
from app.service import notification_service

logger = logging.getLogger(__name__)


def run_stocks_monitor_pipeline() -> None:
    """
    Orchestrates the full pipeline:
    1. Load config from environment
    2. Fetch monitored stocks from DynamoDB
    3. For each stock: fetch market data from CNBC via AgentCore Browser + Claude
    4. Send daily report via SES or SNS
    """
    logger.info("Pipeline started")

    config = AgentConfig()

    session = boto3.Session(region_name=config.aws_region)
    dynamodb_client = session.client("dynamodb")
    bedrock_client = session.client("bedrock-runtime")
    ses_client = session.client("sesv2")
    sns_client = session.client("sns")

    monitored_stocks = dynamodb_repository.fetch_monitored_stocks(
        dynamodb_client, config.stocks_table_name
    )
    logger.info("Monitoring %d stocks", len(monitored_stocks))

    stocks: list[StockMarketData] = []

    for stock in monitored_stocks:
        market_data = browser_repository.fetch_stock_market_data(
            bedrock_client=bedrock_client,
            aws_region=config.aws_region,
            claude_model_id=config.claude_model_id,
            stock_quote_url_template=config.stock_quote_url_template,
            ticker=stock.ticker,
        )
        stocks.append(market_data)

    notification_service.send_daily_report(
        config, ses_client, sns_client, stocks
    )
