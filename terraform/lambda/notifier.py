import json
import os
import boto3

sns = boto3.client("sns")
TOPIC_ARN = os.environ["ALERTS_TOPIC_ARN"]

def lambda_handler(event, context):
    subject = f"[SOAR] {event.get('severity', 'unknown').upper()} - {event.get('type', 'unknown')}"
    message = f"""
SOAR Alert

Type: {event.get('type', 'unknown')}
Severity: {event.get('severity', 'unknown')}
Source: {event.get('source', 'unknown')}
Details: {event.get('details', '')}
Timestamp: {event.get('timestamp', '')}
Source IP: {event.get('source_ip', 'n/a')}

Full Event:
{json.dumps(event, indent=2)}
"""

    response = sns.publish(
        TopicArn=TOPIC_ARN,
        Subject=subject[:100],
        Message=message
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Notification processed",
            "message_id": response["MessageId"]
        })
    }