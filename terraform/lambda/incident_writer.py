import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("INCIDENT_RECORDED %s", json.dumps(event))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Incident processed",
            "event_type": event.get("type", "unknown"),
            "severity": event.get("severity", "unknown")
        })
    }