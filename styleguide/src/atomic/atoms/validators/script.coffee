tv4.setErrorReporter (error, data, schema) ->
  switch error.code
    when tv4.errorCodes.OBJECT_REQUIRED then "#{schema.label} is required"

tv4.defineKeyword 'check-required', (data, props, schema) ->
  if !data
    return code:tv4.errorCodes.OBJECT_REQUIRED, message:{}
