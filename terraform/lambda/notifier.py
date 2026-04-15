import json

def lambda_handler(event, context):
    print("NOTIFIER RECEIVED EVENT:")
    print(json.dumps(event))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Notification processed",
            "source": event.get("source", "unknown"),
            "details": event.get("details", "")
        })
    }