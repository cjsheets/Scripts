TODAY=$(date +%y%m%d)
USER=xxxxx
PASS=xxxxx
URI=xxxxx.mlab.com:12345
DB=xxxxx
COLLECTIONS=("xxxxx" "xxxxy" "xxxxz")
mkdir $TODAY
for COL in "${COLLECTIONS[@]}"
do : 
   mongoexport -h $URI -d $DB -c $COL -u $USER -p $PASS -o "$TODAY/$COL-$TODAY.json"
done
