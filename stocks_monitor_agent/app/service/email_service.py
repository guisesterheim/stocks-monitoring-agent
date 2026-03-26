import os
from datetime import datetime, timezone

from app.model.stock_data import StockMarketData


def build_alert_email_html(stocks: list[StockMarketData], stock_quote_url_template: str) -> str:
    """Loads the HTML email template and injects the stock tiles and timestamp."""
    template_path = os.environ.get("EMAIL_TEMPLATE_PATH", "/app/templates/alert_email.html")
    with open(template_path, "r", encoding="utf-8") as f:
        template = f.read()

    timestamp = datetime.now(timezone.utc).strftime("%B %d, %Y %H:%M UTC")
    tiles = _build_stock_tiles_rows(stocks, stock_quote_url_template)
    return template.replace("{{STOCK_TILES}}", tiles).replace("{{TIMESTAMP}}", timestamp)


def build_sns_plain_text_message(stocks: list[StockMarketData], stock_quote_url_template: str) -> str:
    """Builds a plain-text message body for SNS notifications."""
    lines = []
    for stock in stocks:
        quote_url = stock_quote_url_template.replace("<value>", stock.ticker)
        lines.append(
            f"{stock.ticker}: ${stock.current_price:.2f} | "
            f"Today: {stock.daily_change_percent:+.2f}% | "
            f"5d: {stock.five_day_change_percent:+.2f}% | "
            f"1mo: {stock.thirty_day_change_percent:+.2f}% | "
            f"3mo: {stock.three_month_change_percent:+.2f}% | "
            f"YTD: {stock.ytd_change_percent:+.2f}% | "
            f"1yr: {stock.one_year_change_percent:+.2f}% | "
            f"{quote_url}"
        )
    return "\n".join(lines)


def _build_stock_tiles_rows(stocks: list[StockMarketData], stock_quote_url_template: str) -> str:
    """Builds table rows with 2 stock tiles per row."""
    rows = []
    for i in range(0, len(stocks), 2):
        pair = stocks[i:i + 2]
        cells = "".join(_build_stock_tile_html(stock, stock_quote_url_template) for stock in pair)
        if len(pair) == 1:
            cells += "<td></td>"
        rows.append(f"<tr>{cells}</tr>")
    return "\n".join(rows)


def _build_stock_tile_html(stock: StockMarketData, stock_quote_url_template: str) -> str:
    """Builds a single stock tile as a table cell with inline styles for Gmail compatibility."""
    bg_color = "#2e7d32" if stock.daily_change_percent >= 0 else "#c62828"
    quote_url = stock_quote_url_template.replace("<value>", stock.ticker)

    def fmt(value: float) -> str:
        sign = "+" if value >= 0 else ""
        return f"{sign}{value:.2f}%"

    return (
        f'<td style="background-color: {bg_color}; color: #ffffff; border-radius: 8px; '
        f'padding: 14px 18px; width: 220px; vertical-align: top;">\n'
        f'  <div style="font-size: 20px; font-weight: bold; margin-bottom: 6px;">{stock.ticker}</div>\n'
        f'  <div style="font-size: 16px; margin-bottom: 10px;">${stock.current_price:.2f}</div>\n'
        f'  <div style="font-size: 13px; margin-bottom: 3px;">Today: {fmt(stock.daily_change_percent)}</div>\n'
        f'  <div style="font-size: 13px; margin-bottom: 3px;">5 days: {fmt(stock.five_day_change_percent)}</div>\n'
        f'  <div style="font-size: 13px; margin-bottom: 3px;">1 month: {fmt(stock.thirty_day_change_percent)}</div>\n'
        f'  <div style="font-size: 13px; margin-bottom: 3px;">3 months: {fmt(stock.three_month_change_percent)}</div>\n'
        f'  <div style="font-size: 13px; margin-bottom: 3px;">YTD: {fmt(stock.ytd_change_percent)}</div>\n'
        f'  <div style="font-size: 13px; margin-bottom: 8px;">1 year: {fmt(stock.one_year_change_percent)}</div>\n'
        f'  <a href="{quote_url}" target="_blank" '
        f'style="color: #ffffff; font-size: 12px; opacity: 0.85;">View quote →</a>\n'
        f'</td>\n'
    )
