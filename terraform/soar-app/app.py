from flask import Flask, request, jsonify
import boto3
import os
import json
from datetime import datetime

app = Flask(__name__)

lambda_client = boto3.client("lambda", region_name=os.getenv("AWS_REGION", "eu-central-1"))

INCIDENT_WRITER_FUNCTION = os.getenv("INCIDENT_WRITER_FUNCTION")
NOTIFIER_FUNCTION = os.getenv("NOTIFIER_FUNCTION")


def invoke_lambda(function_name: str, payload: dict) -> dict:
    response = lambda_client.invoke(
        FunctionName=function_name,
        InvocationType="RequestResponse",
        Payload=json.dumps(payload).encode("utf-8")
    )

    raw_payload = response["Payload"].read().decode("utf-8")
    try:
        parsed_payload = json.loads(raw_payload) if raw_payload else {}
    except json.JSONDecodeError:
        parsed_payload = {"raw": raw_payload}

    return {
        "status_code": response.get("StatusCode"),
        "payload": parsed_payload
    }


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/admin", methods=["GET"])
def admin():
    source_ip = request.headers.get("X-Forwarded-For", request.remote_addr)

    event_payload = {
        "type": "unauthorized_access",
        "severity": "high",
        "source": "soar_app",
        "details": "Attempt to access /admin",
        "source_ip": source_ip,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

    app.logger.warning(
        f"UNAUTHORIZED_ACCESS path=/admin source_ip={source_ip} severity=high"
    )

    incident_result = invoke_lambda(INCIDENT_WRITER_FUNCTION, event_payload)
    notifier_result = invoke_lambda(NOTIFIER_FUNCTION, event_payload)

    return jsonify({
        "error": "unauthorized",
        "event": event_payload,
        "incident_writer_result": incident_result,
        "notifier_result": notifier_result
    }), 403


@app.route("/event", methods=["POST"])
def process_event():
    data = request.get_json(silent=True)

    if not data:
        return jsonify({"error": "Invalid or missing JSON body"}), 400

    event_type = data.get("type")
    severity = data.get("severity", "medium")
    source = data.get("source", "unknown")
    details = data.get("details", "")

    if event_type not in ["db_failure", "unauthorized_access"]:
        return jsonify({
            "error": "Unsupported event type",
            "supported_types": ["db_failure", "unauthorized_access"]
        }), 400

    event_payload = {
        "type": event_type,
        "severity": severity,
        "source": source,
        "details": details,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

    if event_type == "unauthorized_access":
        source_ip = request.headers.get("X-Forwarded-For", request.remote_addr)
        event_payload["source_ip"] = source_ip
        app.logger.warning(
            f"UNAUTHORIZED_ACCESS path=/event source_ip={source_ip} severity={severity}"
        )

    incident_result = invoke_lambda(INCIDENT_WRITER_FUNCTION, event_payload)
    notifier_result = invoke_lambda(NOTIFIER_FUNCTION, event_payload)

    return jsonify({
        "message": "SOAR event processed",
        "event": event_payload,
        "incident_writer_result": incident_result,
        "notifier_result": notifier_result
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)