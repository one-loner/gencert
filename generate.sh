#!/bin/bash

# Проверяем, передан ли параметр (название сайта)
if [ $# -ne 1 ]; then
    echo "Usage: $0 <website_name>"
    exit 1
fi

WEBSITE_NAME="$1"
CA_DIR="ca"
WEBSITE_DIR="websites/$WEBSITE_NAME"
CA_KEY="$CA_DIR/ca.key"
CA_CERT="$CA_DIR/ca.crt"
WEBSITE_KEY="$WEBSITE_DIR/$WEBSITE_NAME.key"
WEBSITE_CSR="$WEBSITE_DIR/$WEBSITE_NAME.csr"
WEBSITE_CERT="$WEBSITE_DIR/$WEBSITE_NAME.crt"

# Создаем директории, если они не существуют
mkdir -p "$CA_DIR" "$WEBSITE_DIR"

# Генерируем CA сертификат, если его нет
if [ ! -f "$CA_KEY" ] || [ ! -f "$CA_CERT" ]; then
    openssl req -new -x509 -days 365 -keyout "$CA_KEY" -out "$CA_CERT"
fi

# Генерируем ключ и запрос на подпись сертификата для сайта
openssl req -newkey rsa:2048 -nodes -keyout "$WEBSITE_KEY" -out "$WEBSITE_CSR"

# Подписываем сертификат для сайта с помощью CA сертификата
openssl x509 -req -in "$WEBSITE_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$WEBSITE_CERT" -days 365

echo "Website certificate generated and signed for $WEBSITE_NAME."
