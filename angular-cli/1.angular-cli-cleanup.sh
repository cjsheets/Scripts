rm .editorconfig
mv src client
sed -i -e 's/"root": "src"/"root": "client"/g' angular-cli.json
sed -i -e 's/styles.css/styles.scss/g' angular-cli.json
sed -i -e 's/src/test.ts/client/test.ts/g' karma.conf.json
mv client/styles.css client/styles.scss
ng set defaults.styleExt scss
npm install --save raven-js
printf "\n#Environment\nclient/environments/environment.ts" >> .gitignore