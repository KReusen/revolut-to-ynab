import os

import boto3
from ynab_api import TransactionImportSummary

ses = boto3.client("sesv2")


def send_email(
    recipient: str, subject: str, body: str | None = None, summary: TransactionImportSummary | None = None
) -> dict:
    if not body and not summary:
        raise ValueError("Either body or summary must be provided")

    if not body:
        body = f"Summary: {summary}"

    response = ses.send_email(
        FromEmailAddress=f"ynab@{os.environ["DOMAIN_NAME"]}",
        Destination={"ToAddresses": [recipient]},
        Content={
            "Simple": {
                "Subject": {"Data": subject},
                "Body": {"Text": {"Data": body}},
            }
        },
    )

    return response
