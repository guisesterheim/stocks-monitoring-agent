from dataclasses import dataclass


@dataclass
class MonitoredStock:
    """A stock or index being monitored."""
    ticker: str


@dataclass
class StockMarketData:
    """Price and change data for a ticker fetched from CNBC via AgentCore Browser."""
    ticker: str
    current_price: float
    daily_change_percent: float
    five_day_change_percent: float
    thirty_day_change_percent: float


@dataclass
class StockAlertEvaluation:
    """The result of evaluating alert rules for a single ticker."""
    ticker: str
    market_data: StockMarketData
    daily_alert_triggered: bool
    weekly_alert_triggered: bool
