## Connect to mongo

1. Look up mongo configuration `heroku config`

2. Fill in the template `mongodb://<dbuser>:<dbpassword>@ds023448.mlab.com:23448/heroku_3079lkfw`

3. Add the following collections
```
db.createCollection('Lien')
db.createCollection('LienSub')
db.createCollection('LienCheck')
db.createCollection('LienNote')
db.createCollection('LienOwner')
db.createCollection('LienSub')
db.createCollection('SubBatch')
db.createCollection('Township')
db.createCollection('User')
db.createCollection('Session')
```

4. Create a mono-increasing index on `Lien`
``
