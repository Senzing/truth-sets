
G2Loader.py \
    --fileSpec watchlist.csv/?data_source=WATCHLIST

G2Snapshot.py \
    --output_file_root truthset-load2-snapshot \
    --for_audit

G2Audit.py \
    --newer_csv_file truthset-load2-snapshot.csv \
    --prior_csv_file truthset-load2-key.csv \
    --output_file_root truthset-load2-audit

G2Explorer.py \
    --snapshot_json_file truthset-load2-snapshot.json \
    --audit_json_file truthset-load2-audit.json

