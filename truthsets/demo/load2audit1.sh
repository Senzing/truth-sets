
G2Loader.py \
    --FORCEPURGE \
    --fileSpec customers.csv/?data_source=CUSTOMERS

G2Snapshot.py \
    --output_file_root truthset-load1-snapshot \
    --for_audit

G2Audit.py \
    --newer_csv_file truthset-load1-snapshot.csv \
    --prior_csv_file truthset-load1-key.csv \
    --output_file_root truthset-load1-audit

G2Explorer.py \
    --snapshot_json_file truthset-load1-snapshot.json \
    --audit_json_file truthset-load1-audit.json
