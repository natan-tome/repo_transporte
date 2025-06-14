"""Stream type classes para tap-aw-api (tipos de dados e endpoints)."""

from __future__ import annotations  # ✅ Dois underscores
import typing as t
from importlib import resources

from tap_aw_api.client import AdventureWorksAPIStream

# 📁 Diretório dos schemas (centralizado pra fácil manutenção)
SCHEMAS_DIR = resources.files(__package__) / "schemas"  # ✅ __package__

class SalesOrderDetailStream(AdventureWorksAPIStream):
    """🔍 Stream de detalhes de pedidos de venda (linhas individuais dos pedidos)."""
    name = "SalesOrderDetail"  # 🏷️ Nome da tabela no destino
    path = "/SalesOrderDetail"  # 🌐 Endpoint da API
    schema_filepath = SCHEMAS_DIR / "SalesOrderDetail.json"  # 📄 Schema específico

class SalesOrderHeaderStream(AdventureWorksAPIStream):
    """📦 Stream de cabeçalho de pedidos de venda (metadados principais)."""
    name = "SalesOrderHeader"
    path = "/SalesOrderHeader"
    schema_filepath = SCHEMAS_DIR / "SalesOrderHeader.json"

class PurchaseOrderDetailStream(AdventureWorksAPIStream):
    """📋 Stream de detalhes de ordens de compra (itens comprados de fornecedores)."""
    name = "PurchaseOrderDetail"
    path = "/PurchaseOrderDetail"
    schema_filepath = SCHEMAS_DIR / "PurchaseOrderDetail.json"

class PurchaseOrderHeaderStream(AdventureWorksAPIStream):
    """📑 Stream de cabeçalho de ordens de compra (informações gerais de aquisição)."""
    name = "PurchaseOrderHeader"
    path = "/PurchaseOrderHeader"
    schema_filepath = SCHEMAS_DIR / "PurchaseOrderHeader.json"
