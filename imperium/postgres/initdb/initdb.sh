#!/bin/bash

# Array of credentials: each entry is "DB_NAME:DB_USER:DB_PASSWORD"
CREDENTIALS=(
  "$HYDRA_POSTGRES_DB:$HYDRA_POSTGRES_USER:$HYDRA_POSTGRES_PASSWORD"
  "$KETO_POSTGRES_DB:$KETO_POSTGRES_USER:$KETO_POSTGRES_PASSWORD"
  "$KRATOS_POSTGRES_DB:$KRATOS_POSTGRES_USER:$KRATOS_POSTGRES_PASSWORD"
  "$OATHKEEPER_POSTGRES_DB:$OATHKEEPER_POSTGRES_USER:$OATHKEEPER_POSTGRES_PASSWORD"
)

# Loop through the credentials array
for CREDENTIAL in "${CREDENTIALS[@]}"; do
  # Split the credential string into components
  IFS=':' read -r DB_NAME DB_USER DB_PASSWORD <<< "$CREDENTIAL"

  # Check if all components are set
  if [[ -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
    echo "Skipping incomplete credential: $CREDENTIAL"
    continue
  fi

  # Create the database
  echo "Creating database: $DB_NAME"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE "$DB_NAME";
EOSQL

  # Create the user and set the password
  echo "Creating user: $DB_USER"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER "$DB_USER" WITH PASSWORD '$DB_PASSWORD';
    GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
EOSQL
done

echo "Database and user creation completed."
