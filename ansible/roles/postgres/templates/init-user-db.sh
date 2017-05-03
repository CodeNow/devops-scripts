apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ name }}-init-user-db
data:
  init-user-db.sh: |
    #!/bin/bash
    set -e

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE DATABASE {{ egret_pg_database }} IF NOT EXISTS;
        GRANT ALL PRIVILEGES ON DATABASE {{ egret_pg_database }} TO {{ pg_user }};
        CREATE DATABASE {{ arithmancy_pg_database }} IF NOT EXISTS;
        GRANT ALL PRIVILEGES ON DATABASE {{ arithmancy_pg_database }} TO {{ pg_user }};
        CREATE DATABASE {{ big_poppa_pg_database }} IF NOT EXISTS;
        GRANT ALL PRIVILEGES ON DATABASE {{ big_poppa_pg_database }} TO {{ pg_user }};
    EOSQL
