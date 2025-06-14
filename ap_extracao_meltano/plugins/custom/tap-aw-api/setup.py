from setuptools import setup, find_packages

# 🛠️ Configuração do pacote Python (distribuição e dependências)
setup(
    # 📦 Metadados básicos do pacote
    name="tap-aw-api",  # 🏷️ Nome do pacote no PyPI
    version="0.1.0",  # 🚀 Versão semântica (major.minor.patch)
    description="Custom Singer tap for AwAPI",  # 📝 Descrição curta
    
    # 🔍 Configuração de descoberta de pacotes
    packages=find_packages(),  # 🕵️♂️ Encontra todos os subpacotes automaticamente
    include_package_data=True,  # 📁 Inclui arquivos não-PY (schemas, etc)
    
    # 📦 Dependências essenciais
    install_requires=[
        "singer-sdk>=0.34.0",  # 🧰 SDK base para desenvolvimento de taps
        "requests",  # 🔌 Cliente HTTP para conexão com APIs
    ],
    
    # 💻 Configuração de linha de comando
    entry_points={
        "console_scripts": [
            # 🖥️ Comando CLI principal (integração com o Meltano)
            "tap-aw-api=tap_aw_api.tap:TapAwAPI.cli",
        ],
    },
    
    # 📄 Metadados adicionais (opcional)
    author="Natan Tomé",
    author_email="natan.tome@indicium.tech",
    # url="https://github.com/seu-usuario/tap-adventureworksapi",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
    ],
)