from app.model.stock_data import StockAlertEvaluation, StockMarketData


def evaluate_stock_alerts(
    market_data: StockMarketData,
    daily_drop_threshold_percent: float,
    weekly_drop_threshold_percent: float,
) -> StockAlertEvaluation:
    """Evaluates whether a stock has triggered daily or weekly alert thresholds."""
    daily_alert_triggered = market_data.daily_change_percent <= -daily_drop_threshold_percent
    weekly_alert_triggered = market_data.five_day_change_percent <= -weekly_drop_threshold_percent

    return StockAlertEvaluation(
        ticker=market_data.ticker,
        market_data=market_data,
        daily_alert_triggered=daily_alert_triggered,
        weekly_alert_triggered=weekly_alert_triggered,
    )
