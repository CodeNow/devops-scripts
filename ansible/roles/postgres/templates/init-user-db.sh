apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ name }}-init-user-db
data:
  init-user-db.sh: |
    #!/bin/bash
    set -e

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE DATABASE {{ egret_pg_database }};
        GRANT ALL PRIVILEGES ON DATABASE {{ egret_pg_database }} TO {{ egret_pg_database }};
        CREATE DATABASE {{ arithmancy_pg_database }};
        GRANT ALL PRIVILEGES ON DATABASE {{ arithmancy_pg_database }} TO {{ arithmancy_pg_database }};
        CREATE DATABASE {{ big_poppa_pg_database }};
        GRANT ALL PRIVILEGES ON DATABASE {{ big_poppa_pg_database }} TO {{ big_poppa_pg_database }};
    EOSQL
