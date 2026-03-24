import json
import os


class AgentConfig:
    """All runtime configuration loaded from environment variables."""

    def __init__(self):
        self.aws_region = self._require("AWS_REGION_NAME")
        self.stocks_table_name = self._require("STOCKS_TABLE_NAME")
        self.sns_topic_arn = self._require("SNS_TOPIC_ARN")
        self.claude_model_id = self._require("CLAUDE_MODEL_ID")
        self.daily_drop_threshold_percent = float(self._require("DAILY_DROP_THRESHOLD_PERCENT"))
        self.weekly_drop_threshold_percent = float(self._require("WEEKLY_DROP_THRESHOLD_PERCENT"))

        recipient_json = self._require("RECIPIENT_EMAIL_ADDRESSES")
        self.recipient_email_addresses: list[str] = json.loads(recipient_json)

        self.sender_email_address = os.environ.get("SENDER_EMAIL_ADDRESS", "")
        self.use_ses = os.environ.get("USE_SES", "false").lower() == "true"

    @staticmethod
    def _require(name: str) -> str:
        value = os.environ.get(name)
        if not value:
            raise EnvironmentError(f"Required environment variable '{name}' is missing or empty")
        return value
