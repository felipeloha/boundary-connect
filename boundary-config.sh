declare -A URL_MAPPING=(
  ["testing"]="https://boundary-controller.testing.de"
  ["staging"]="https://boundary-controller.staging.de"
)
declare -A METHOD_ID_MAPPING=(
  ["testing"]="amoidc_54321"
  ["staging"]="amoidc_12345"
)
declare -A PORT_MAPPING=(
  ["my-db"]=49820
  ["my-sql-db"]=49821
  ["my-postgres-db"]=49822
)