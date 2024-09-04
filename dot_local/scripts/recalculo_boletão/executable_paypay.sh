#!/bin/sh

INPUT_FILE="./pay_charge_request.txt"
LOG="./pay_charge_request_curls_result.txt"

# ler arquivo com baixa e tenant
while read -r line; do
    # acquittance_id="$(echo "$line" | awk '{print $1}')"
    # tenant_id="$(echo "$line" | awk '{print $2}')"

    # echo "$acquittance_id $tenant_id"
    # echo "$acquittance_id $tenant_id" >> "$LOG"

    # curl_text="curl curl -o /dev/null -s -w \"%{http_code}\\n\" --location --request DELETE 'http://finance-pro.prod.contaazul.local/v1/acquittances/$acquittance_id' --header 'X-TenantId: $tenant_id' --header 'X-UserId: -1'"

    # echo "$curl_text" >> "$CURLS_FILE"
    eval "$line" >> "$LOG"
    echo "\n" >> "$LOG"
    sleep 0.5s
done <$INPUT_FILE
