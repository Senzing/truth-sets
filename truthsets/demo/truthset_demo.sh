export SCRIPTDIR=$(dirname "$0")

sz_command -C "purge_repository --FORCEPURGE"

sz_file_loader -f ${SCRIPTDIR}/*.jsonl  
# sz_file_loader -f ${SCRIPTDIR}/customers.jsonl
# sz_file_loader -f ${SCRIPTDIR}/watchlist.jsonl
# sz_file_loader -f ${SCRIPTDIR}/reference.jsonl

sz_snapshot -QAo ${SCRIPTDIR}/truthset_snapshot

sz_audit -n ${SCRIPTDIR}/truthset_snapshot.csv -p ${SCRIPTDIR}/truthset_key.csv -o ${SCRIPTDIR}/truthset_audit

sz_explorer -s ${SCRIPTDIR}/truthset_snapshot.json -a ${SCRIPTDIR}/truthset_audit.json

