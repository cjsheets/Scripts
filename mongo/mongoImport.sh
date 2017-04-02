TODAY=$(date +%y%m%d)
USER=xxxxx
PASS=xxxxx
URI=xxxxx.mlab.com:12345
DB=xxxxx
COLLECTIONS=("users" "settings")
mkdir $TODAY
for COL in "${COLLECTIONS[@]}"
do : 
    mongoimport -h $URI -d $DB -c $COL -u $USER -p $PASS --file "$TODAY/$COL-$TODAY.json"
done
