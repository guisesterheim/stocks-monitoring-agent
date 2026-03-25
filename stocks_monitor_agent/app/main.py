import logging
import time

from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse

from app.controller.agent_controller import run_stocks_monitor_pipeline

logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp": "%(asctime)s", "level": "%(levelname)s", "message": "%(message)s", "logger": "%(name)s"}',
)
logger = logging.getLogger(__name__)

app = FastAPI()

@app.get("/ping")
def handle_ping():
    """Health check endpoint required by AgentCore Runtime."""
    logger.info("Ping OK")
    return {"status": "Healthy", "time_of_last_update": int(time.time())}


@app.post("/invocations")
def handle_invocation(request: Request):
    """Handles invocation requests from AgentCore Runtime."""
    try:
        run_stocks_monitor_pipeline()
        return JSONResponse(content={"status": "ok"})
    except Exception as e:
        logger.error("Pipeline failed: %s", str(e), exc_info=True)
        return Response(status_code=500)
