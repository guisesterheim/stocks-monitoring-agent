import base64
import json
import logging
import os
import time
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """Lambda handler — invoked by EventBridge Scheduler on a daily schedule.
    Calls InvokeAgentRuntime on the configured AgentCore Runtime ARN.
    """
    runtime_arn = os.environ["AGENTCORE_RUNTIME_ARN"]

    client = boto3.client("bedrock-agentcore", region_name="us-east-1")

    session_id = _generate_session_id()
    payload = json.dumps({"run": "scheduled_daily_run"}).encode()

    logger.info("Invoking AgentCore Runtime: %s", runtime_arn)

    response = client.invoke_agent_runtime(
        agentRuntimeArn=runtime_arn,
        runtimeSessionId=session_id,
        contentType="application/json",
        accept="application/json",
        payload=payload,
    )

    response_body = response["response"].read()
    logger.info("AgentCore Runtime invoked successfully. Response: %s", response_body)

    return {"status": "ok"}

def _generate_session_id() -> str:
    """Generates a unique session ID satisfying AgentCore's constraint:
    minimum 33 characters, pattern [a-zA-Z0-9][a-zA-Z0-9-_]*
    """
    ts = int(time.time() * 1000)
    return f"sched-{ts:013d}-{ts:013d}"
