## Connect to mongo

1. Look up mongo configuration `heroku config`

2. Fill in the template `mongo ds023448.mlab.com:23448/heroku_3079lkfw -u <dbuser> -p <dbpassword>`

3. Add the following collections
```
db.createCollection('Lien')
db.Lien.createIndex( { seq_id: 1 } )
db.createCollection('LienSub')
db.createCollection('LienCheck')
db.createCollection('LienNote')
db.createCollection('LienOwner')
db.createCollection('LienSub')
db.createCollection('SubBatch')
db.createCollection('Township')
db.createCollection('User')
db.createCollection('Session')
db.createCollection('counters')
db.counters.insert(
   {
      _id: "lien_id",
      seq: 0
   }
)
```


magic:  git push --force heroku `git subtree split --prefix server HEAD`:master
heroku run rake db:migrate
