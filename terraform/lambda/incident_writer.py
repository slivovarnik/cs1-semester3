import json

def lambda_handler(event, context):
    print("INCIDENT WRITER RECEIVED EVENT:")
    print(json.dumps(event))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Incident processed",
            "event_type": event.get("type", "unknown"),
            "severity": event.get("severity", "unknown")
        })
    }