TODAY=$(date +%y%m%d)
USER=xxxxx
PASS=xxxxx
URI=xxxxx.mlab.com:12345
DB=xxxxx
mkdir $TODAY-db
mongodump -h $URI -d $DB -u $USER -p $PASS -o "$TODAY-db"
