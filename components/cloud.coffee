Parse.Cloud.define 'delete', (request, response) ->
  query = new (Parse.Query)('Lien')
  query.find().then( (liens) ->
    Parse.Object.destroyAll(liens)
  ).then( ->
    query = new (Parse.Query)('LienSub')
    query.find()
  ).then( (subs) ->
    Parse.Object.destroyAll(subs)
  ).then( ->
    query = new (Parse.Query)('LienCheck')
    query.find()
  ).then( (checks) ->
    Parse.Object.destroyAll(checks)
  ).then( ->
    query = new (Parse.Query)('LienNote')
    query.find()
  ).then( (notes) ->
    Parse.Object.destroyAll(notes)
  ).then( ->
    query = new (Parse.Query)('Township')
    query.find()
  ).then( (townships) ->
    Parse.Object.destroyAll(townships)
  ).then( ->
    query = new (Parse.Query)('SubBatch')
    query.find()
  ).then( (batches) ->
    Parse.Object.destroyAll(batches)
  ).then( ->
    query = new (Parse.Query)('LienOwner')
    query.find()
  ).then( (owners) ->
    Parse.Object.destroyAll(owners)
  ).then( ->
      response.success("success");
  ).fail( ->
    response.error("error")
  )
  return

Parse.Cloud.beforeSave 'Lien', (request, response) ->
  if request.object.isNew()
    query = new (Parse.Query)('Lien')
    query.equalTo 'objectId', request.object.id
    return query.find().then( (liens) ->
      if liens.length == 0
        response.success()
      else
        response.error("Lien already created with this objectId")
    ).fail( (error) ->
      response.error(error)
    )
  else
    response.success()
  return

Parse.Cloud.beforeSave 'LienSub', (request, response) ->
  if request.object.isNew()
    query = new (Parse.Query)('Lien')
    query.equalTo 'type', request.object.get('type')
    query.equalTo 'sub_date', request.object.get('sub_date')
    return query.find().then( (liens) ->
      if liens.length == 0
        response.success()
      else
        response.error("LienSub already created with this objectId")
    ).fail( (error) ->
      response.error(error)
    )
  else
    response.success()
  return

Parse.Cloud.beforeSave 'Township', (request, response) ->
  if request.object.isNew()
    query = new (Parse.Query)('Township')
    query.equalTo 'township', request.object.get('township')
    return query.find().then( (townships) ->
      if townships.length == 0
        response.success()
      else
        response.error("township already created with this objectId")
    ).fail( (error) ->
      response.error(error)
    )
  else
    response.success()
  return
