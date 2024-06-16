import json
import logging
from dataclasses import asdict, dataclass
from hashlib import blake2b

from http_request import HTTPRequest

logger = logging.getLogger()


@dataclass
class TransactionImportSummary:
    transactions_imported: int
    duplicates_skipped: int

    def to_dict(self) -> dict:
        return asdict(self)


class YNABApi:
    def __init__(self, api_key: str, budget_id: str, account_id: str) -> None:
        self.api_key = api_key
        self.budget_id = budget_id
        self.account_id = account_id
        self.host = "api.ynab.com"
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}",
        }

    def send_transactions(self, revolut_transactions: list[dict]) -> TransactionImportSummary:
        ynab_transactions = [
            {
                "account_id": self.account_id,
                "date": tr["Started Date"][:10],
                "amount": int(round(float(tr["Amount"]) * 1000)),
                "cleared": "cleared",
                "payee_name": tr["Description"],
                "import_id": self._create_import_id(tr),
            }
            for tr in revolut_transactions
        ]

        logging.info(json.dumps(ynab_transactions))

        response = HTTPRequest.post(
            host=self.host,
            endpoint=f"/v1/budgets/{self.budget_id}/transactions",
            payload={"transactions": ynab_transactions},
            headers=self.headers,
        ).json()

        return TransactionImportSummary(
            transactions_imported=len(response["data"]["transaction_ids"]),
            duplicates_skipped=len(response["data"]["duplicate_import_ids"]),
        )

    @staticmethod
    def _create_import_id(revolut_transaction: dict) -> str:
        """Returns a reproducible import_id for a given Revolut transaction, of 36 characters."""

        version = (
            "v1"  # update this if the import_id format changes, or if you want to invalidate all previous import_ids
        )
        input_string = "{}:{}:{}".format(
            revolut_transaction["Started Date"],
            revolut_transaction["Amount"],
            revolut_transaction["Description"],
        )
        blake2_hash = blake2b(digest_size=17)
        blake2_hash.update(input_string.encode("utf-8"))
        return version + blake2_hash.hexdigest()
