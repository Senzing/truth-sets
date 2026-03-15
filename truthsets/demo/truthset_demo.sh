export SCRIPTDIR=$(dirname "$0")

echo "This will purge all data from your Senzing repository."
read -p "Type YESPURGESENZING to confirm: " CONFIRM
if [ "$CONFIRM" = "YESPURGESENZING" ]; then
    sz_command -C "purge_repository --FORCEPURGE"
else
    echo "Purge skipped."
    read -p "Do you still want to load the truth set? (y/n): " LOADCONFIRM
    if [ "$LOADCONFIRM" != "y" ]; then
        echo "Exiting."
        exit 0
    fi
fi

sz_configtool -f ${SCRIPTDIR}/truthset_config.g2c

sz_file_loader -f ${SCRIPTDIR}/*.jsonl

sz_snapshot -QAo truthset_snapshot

sz_audit -n truthset_snapshot.csv -p ${SCRIPTDIR}/alternate_truthset_key.csv -o truthset_audit

sz_explorer -s truthset_snapshot.json -a truthset_audit.json

