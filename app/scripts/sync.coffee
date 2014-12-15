Backbone.sync = _.wrap Backbone.sync, (originalSync, method, model, options) ->
  if App.isOnline
    if options.success
      options.success = _.wrap options.success, (func, args...) ->
        if method isnt 'delete'
          App.offlineServer.cacheServerResponse args[0]
        else
          App.dbCached.deleteContactById model.id
        func.apply @, args
    else
      options.success = App.offlineServer.cacheServerResponse
    originalSync(method, model, options)
  else
    App.offlineServer[method](model)
      .done (resp) ->
        if options.success then options.success resp
      .fail (err) ->
        if options.error then options.error model, status: 404
