"""REST client handling, incluindo a base AdventureWorksAPIStream."""

from __future__ import annotations  # ✅ Compatibilidade futura de tipos

import sys
import typing as t
from importlib import resources
from requests.adapters import HTTPAdapter
from requests.sessions import Session
from urllib3.util.retry import Retry

from requests.auth import HTTPBasicAuth
from singer_sdk.helpers.types import Context
from singer_sdk.streams import RESTStream

if t.TYPE_CHECKING:
    from requests import Response  # ✅ Tipagem específica para type checking
else:
    Response = t.Any  # ✅ Fallback para tempo de execução

# 📁 Diretório dos schemas (organização centralizada)
SCHEMAS_DIR = resources.files(__package__) / "schemas"


class AdventureWorksAPIStream(RESTStream):
    """Classe base para streams da TapAwAPI 🔌"""

    # 🔎 Caminho JSON para extração dos registros
    records_jsonpath = "$.data[*]"

    @property
    def url_base(self) -> str:
        # 🌐 URL base configurável (fallback para ambiente de desenvolvimento)
        return self.config.get("api_url", "http://18.209.218.63:8080")

    @property
    def authenticator(self) -> HTTPBasicAuth:
        # 🔐 Autenticação básica (credenciais seguras via config)
        return HTTPBasicAuth(
            username=self.config.get("username"),
            password=self.config.get("password"),
        )

    @property
    def http_headers(self) -> dict:
        # 📄 Headers HTTP (customizáveis por herança)
        return {}

    def get_url_params(
        self,
        context: Context | None,
        next_page_token: t.Any | None,
    ) -> dict[str, t.Any]:
        # 🎚️ Parâmetros de paginação dinâmica
        dynamic_limit = getattr(self, "_dynamic_limit", None)
        default_limit = int(
            self.config.get("pagination", {}).get("page_size") 
            or self.config.get("limit", 10000)
        )

        return {
            "offset": next_page_token or 0,
            "limit": dynamic_limit or default_limit
        }

    @property
    def requests_session(self) -> Session:
        # 🔄 Session com retry inteligente (resiliência contra falhas)
        session = super().requests_session
        adapter = HTTPAdapter(
            max_retries=Retry(
                total=3,
                backoff_factor=0.3,
                status_forcelist=[500, 502, 503, 504],
                allowed_methods=["GET"]
            )
        )
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        session.request = self._wrap_request_with_timeout(session.request)
        return session

    def _wrap_request_with_timeout(self, request_func):
        # ⏱️ Timeout padrão para evitar requisições travadas
        def wrapper(method, url, **kwargs):
            kwargs.setdefault("timeout", 10)
            return request_func(method, url, **kwargs)
        return wrapper

    def get_next_page_token(self, response, previous_token):
        # 📊 Lógica de paginação adaptativa
        payload = response.json()
        offset = int(payload.get("offset", 0))
        total = int(payload.get("total", 0))

        # 🚦 Ajuste dinâmico do limite na primeira página
        if previous_token is None:
            limit = min(total, int(self.config.get("limit", 10000)))
            self._dynamic_limit = limit
        else:
            limit = getattr(self, "_dynamic_limit", int(self.config.get("limit", 10000)))

        next_offset = offset + limit
        if next_offset < total:
            self.logger.info(f"Paginação: offset={offset}, limit={limit}, total={total} 📈")
            return next_offset
        return None

    def prepare_request_payload(
        self,
        context: Context | None,
        next_page_token: t.Any | None,
    ) -> dict | None:
        # 🚫 Sem payload para métodos GET (padrão REST)
        return None

    def parse_response(self, response: Response) -> t.Iterable[dict]:
        # 📥 Processamento inicial da resposta
        self.logger.info(f"Resposta recebida: {response.url} [status={response.status_code}]")
        try:
            data = response.json().get("data", [])
            self.logger.info(f"Registros processados: {len(data)} ✅")
            return data
        except Exception as e:
            self.logger.error(f"Falha no parse JSON: {str(e)} ❌")
            return []

    def post_process(self, row: dict, context: Context | None = None) -> dict | None:
        # 🧼 Garantia de flush para logs em tempo real
        sys.stdout.flush()
        return row
