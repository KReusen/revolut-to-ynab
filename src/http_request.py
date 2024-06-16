import http.client
import json
from dataclasses import dataclass


class HTTPStatusError(Exception):
    pass


@dataclass
class Response:
    status: int
    data: str

    def json(self) -> dict:
        return json.loads(self.data)

    def raise_for_status(self) -> None:
        if self.status >= 400:  # noqa: PLR2004
            raise HTTPStatusError(f"Request failed with status {self.status}: {self.data}")


class HTTPRequest:
    @staticmethod
    def post(host: str, endpoint: str, payload: dict, headers: dict) -> Response:
        """Post request using only Python standard library."""
        data = json.dumps(payload)

        conn = http.client.HTTPSConnection(host)
        conn.request("POST", endpoint, body=data, headers=headers)
        res = conn.getresponse()
        response = Response(
            status=res.status,
            data=res.read().decode(),
        )

        conn.close()

        return response
