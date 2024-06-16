import csv
import json
import logging
import os
import traceback
from email import policy
from email.parser import BytesParser
from io import StringIO

import boto3
from notify import send_email
from ynab_api import YNABApi

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", logging.INFO))

ALLOWED_SENDERS: list[str] = os.environ.get("ALLOWED_SENDERS", "").split(",")
S3 = boto3.client("s3")
ssm = boto3.client("ssm")

ssm_prefix = f"/{os.environ['PROJECT_NAME_WITH_ENV']}/"
parameters = ssm.get_parameters_by_path(
    Path=ssm_prefix,
    Recursive=True,
    WithDecryption=True,
)

SECRETS = {p["Name"].removeprefix(ssm_prefix): p["Value"] for p in parameters.get("Parameters", [])}

YNAB_API = YNABApi(
    api_key=SECRETS["ynab_access_token"],
    budget_id=SECRETS["ynab_budget_id"],
    account_id=SECRETS["ynab_account_id"],
)


def handler(event: dict, context: object) -> dict:
    logging.info(json.dumps(event))

    for record in event.get("Records", []):
        bucket_name = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]
        response = S3.get_object(Bucket=bucket_name, Key=object_key)

        email_content = response["Body"].read()
        msg = BytesParser(policy=policy.default).parsebytes(email_content)

        sender = msg.get("from")
        if not any(s in sender for s in ALLOWED_SENDERS):  # type: ignore[operator]
            # silently ignore emails from unknown senders
            return {"statusCode": 403, "body": json.dumps("Forbidden")}

        # Loop over the email parts to find attachments
        attachments = [
            part.get_payload(decode=True).decode("utf-8")
            for part in msg.iter_parts()  # type: ignore[attr-defined]
            if part.get_content_type() == "text/csv"
        ]

        if not attachments:
            send_email(
                recipient=sender,
                subject="Transaction import FAILED - No attachments found",
                body="No attachments found in the email. Please attach a CSV file with transactions.",
            )
            return {"statusCode": 400, "body": json.dumps("No attachments found")}

        for attachment in attachments:
            try:
                csv_reader = csv.DictReader(StringIO(attachment))
                json_data = list(csv_reader)

                logging.info(json.dumps({"message": "Sending transactions to YNAB", "transactions": json_data}))
                summary = YNAB_API.send_transactions(json_data)
                logging.info(json.dumps({"message": "Transactions imported by YNAB", "summary": summary.to_dict()}))

                send_email(
                    recipient=sender,
                    subject="Transaction import complete",
                    summary=summary,
                )
            except Exception as e:
                logging.exception(e)
                send_email(
                    recipient=sender,
                    subject=f"Transaction import FAILED - {e}",
                    body=f"An error occurred while processing the transactions: {e}\n\n"
                    f"Traceback:\n{traceback.format_exc()}",
                )

    return {"statusCode": 200, "body": json.dumps("Processed successfully")}
