offlineServer = new OfflineServer

Backbone.sync = _.wrap Backbone.sync, (originalSync, method, model, options) ->
  if App.isOnline
    if options.success
      options.success = _.wrap options.success, (func, args...) ->
        if method isnt 'delete'
          offlineServer.cacheServerResponse args[0]
        else
          App.dbCached.deleteContactById model.id
        func.apply @, args
    else
      options.success = offlineServer.cacheServerResponse
    originalSync(method, model, options)

  else
    if method is 'create'
      offlineServer.create(model)
        .done (resp) ->
          if options.success then options.success resp
    else if method is 'read'
      offlineServer.read(model)
        .done (resp) ->
          if options.success then options.success resp
        .fail (err) ->
          if options.error then options.error model, status: 404
    else if method is 'update'
      offlineServer.update(model)
        .done (resp) ->
          if options.success then options.success resp
        .fail (err) ->
          if options.error then options.error model, status: 404
    else if method is 'delete'
      offlineServer.delete(model)
        .done (resp) ->
          if options.success then options.success resp
        .fail (err) ->
          if options.error then options.error model, status: 404
