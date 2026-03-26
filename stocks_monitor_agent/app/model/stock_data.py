from dataclasses import dataclass


@dataclass
class MonitoredStock:
    """A stock or index being monitored."""
    ticker: str


@dataclass
class StockMarketData:
    """Price and change data for a ticker fetched via AgentCore Browser."""
    ticker: str
    current_price: float
    daily_change_percent: float
    five_day_change_percent: float
    thirty_day_change_percent: float
    three_month_change_percent: float
    ytd_change_percent: float
    one_year_change_percent: float
