import json
import logging
import uuid

import boto3
from bedrock_agentcore.tools.browser_client import BrowserClient
from playwright.sync_api import sync_playwright

from app.model.stock_data import StockMarketData

logger = logging.getLogger(__name__)

BROWSER_IDENTIFIER = "aws.browser.v1"


def fetch_stock_market_data_from_cnbc(
    bedrock_client,
    aws_region: str,
    claude_model_id: str,
    ticker: str,
) -> StockMarketData:
    """Uses AgentCore Browser to fetch CNBC page content, then Claude to extract market data."""
    page_content = browse_cnbc_quote_page(aws_region, ticker)
    return extract_market_data_with_claude(bedrock_client, claude_model_id, ticker, page_content)


def browse_cnbc_quote_page(aws_region: str, ticker: str) -> str:
    """Starts an AgentCore Browser session, navigates to the CNBC quote page, and returns page text."""
    url = f"https://www.cnbc.com/quotes/{ticker}"
    logger.info("Browsing CNBC page for ticker '%s': %s", ticker, url)

    browser_client = BrowserClient(region=aws_region, browser_identifier=BROWSER_IDENTIFIER)

    with sync_playwright() as playwright:
        ws_url, headers = browser_client.generate_ws_headers()
        browser = playwright.chromium.connect_over_cdp(ws_url, headers=headers)

        context = browser.contexts[0] if browser.contexts else browser.new_context()
        page = context.pages[0] if context.pages else context.new_page()

        page.goto(url, wait_until="networkidle", timeout=30000)
        page_text = page.inner_text("body")

        browser.close()

    logger.info("Fetched CNBC page content for ticker '%s' (%d chars)", ticker, len(page_text))
    return page_text


def extract_market_data_with_claude(
    bedrock_client,
    claude_model_id: str,
    ticker: str,
    page_content: str,
) -> StockMarketData:
    """Uses Claude via Bedrock to extract structured market data from raw CNBC page text."""
    prompt = (
        f"You are a financial data parser. From the following CNBC page content for ticker '{ticker}', "
        "extract exactly these four values:\n"
        "- current_price: the current stock price as a number\n"
        "- daily_change_percent: the percentage change today (positive = up, negative = down)\n"
        "- five_day_change_percent: the percentage change over the last 5 days\n"
        "- thirty_day_change_percent: the percentage change over the last 30 days\n\n"
        "Respond ONLY with a valid JSON object in this exact format, no explanation:\n"
        '{"current_price": 0.0, "daily_change_percent": 0.0, "five_day_change_percent": 0.0, "thirty_day_change_percent": 0.0}\n\n'
        f"Page content:\n{page_content}"
    )

    response = bedrock_client.converse(
        modelId=claude_model_id,
        messages=[{"role": "user", "content": [{"text": prompt}]}],
    )

    response_text = response["output"]["message"]["content"][0]["text"]
    logger.info("Claude response for ticker '%s': %s", ticker, response_text)

    parsed = json.loads(response_text)
    return StockMarketData(
        ticker=ticker,
        current_price=float(parsed["current_price"]),
        daily_change_percent=float(parsed["daily_change_percent"]),
        five_day_change_percent=float(parsed["five_day_change_percent"]),
        thirty_day_change_percent=float(parsed["thirty_day_change_percent"]),
    )
