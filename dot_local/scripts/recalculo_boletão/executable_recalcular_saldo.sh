#!/bin/sh

INPUT_FILE="./tenants_para_recalcular.txt"
LOG_FILE="./recalculate_log.txt"

while read -r line; do
    tenant_id="$line"

    echo "$tenant_id"
    echo "$tenant_id" >> "$LOG_FILE"

    curl_text="curl -o /dev/null -s -w \"%{http_code}\\n\" --location --request POST 'http://finance-pro.prod.contaazul.local/v1/monthly-balances/recalculate' --header 'X-TenantId: $tenant_id' --header 'X-UserId: -1'"

    # echo "$curl_text" >> "$CURLS_FILE"
    eval "$curl_text" >> "$LOG_FILE"
done <$INPUT_FILE

# while read -r line; do
#     eval "$line"

#     # echo "$acquittance_id"
#     # echo "$tenant_id"

#     curl_text="curl --location --request DELETE 'http://finance-pro.prod.contaazul.local/v1/acquittances/$acquittance_id' --header 'X-TenantId: $tenant_id' --header 'X-UserId: -1'"
#     echo "$curl_text" >> curls.txt
# done <$CURLS_FILE
