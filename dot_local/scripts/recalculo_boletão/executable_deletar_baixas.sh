#!/bin/sh

INPUT_FILE="./acquittances_para_deletar.txt"
CURLS_FILE="./curls_deleção_gerados.txt"
LOG="deleção_log.txt"

# ler arquivo com baixa e tenant
while read -r line; do
    acquittance_id="$(echo "$line" | awk '{print $1}')"
    tenant_id="$(echo "$line" | awk '{print $2}')"

    echo "$acquittance_id $tenant_id"
    echo "$acquittance_id $tenant_id" >> "$LOG"

    curl_text="curl -o /dev/null -s -w \"%{http_code}\\n\" --location --request DELETE 'http://finance-pro.prod.contaazul.local/v1/acquittances/$acquittance_id' --header 'X-TenantId: $tenant_id' --header 'X-UserId: -1'"

    echo "$curl_text" >> "$CURLS_FILE"
    eval "$curl_text" >> "$LOG"
done <$INPUT_FILE

# while read -r line; do
#     eval "$line"

#     # echo "$acquittance_id"
#     # echo "$tenant_id"

#     curl_text="curl --location --request DELETE 'http://finance-pro.prod.contaazul.local/v1/acquittances/$acquittance_id' --header 'X-TenantId: $tenant_id' --header 'X-UserId: -1'"
#     echo "$curl_text" >> curls.txt
# done <$CURLS_FILE
