"""TapAwAPI tap class."""

from __future__ import annotations  # ✅ Dois underscores
from singer_sdk import Tap, typing as th

from tap_aw_api.streams import (
    SalesOrderDetailStream,
    SalesOrderHeaderStream,
    PurchaseOrderDetailStream,
    PurchaseOrderHeaderStream,
)

class TapAwAPI(Tap):
    """🔌 Tap principal para extração de dados da TapAwAPI."""
    
    name = "tap-aw-api"  # 🏷️ Nome do pacote no Meltano

    config_jsonschema = th.PropertiesList(
        # 🔐 Credenciais de autenticação
        th.Property("username", th.StringType, required=True),
        th.Property("password", th.StringType, required=True, secret=True),
        
        # 🌐 Configurações de conexão
        th.Property("api_url", th.StringType, default="http://18.209.218.63:8080"),
        
        # 📊 Controle de volume de dados
        th.Property("limit", th.IntegerType, default=10000)
    ).to_dict()

    def discover_streams(self):
        """📚 Lista de streams disponíveis no tap."""
        return [
            SalesOrderDetailStream(self),
            SalesOrderHeaderStream(self),
            PurchaseOrderDetailStream(self),
            PurchaseOrderHeaderStream(self),  # ✅ Sem caracteres invisíveis
        ]