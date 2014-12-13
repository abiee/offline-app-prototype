NOT_FOUND = 404
class OfflineServer
  generateIntemediateId: ->
    date = new Date
    "#{date.getYear()}#{date.getMonth()}#{date.getDay()}#{date.getHours()}" + \
    "#{date.getMinutes()}#{date.getMilliseconds()}"

  create: (model) ->
    deferred = $.Deferred()
    data = model.toJSON()
    data._id = @generateIntemediateId()
    data.status = 'CREATED'

    App.dbCached.storeContact(data).done ->
      deferred.resolve _.omit data, 'status'

    deferred.promise()

  read: (model) ->
    if model instanceof Backbone.Collection
      @_readAsCollection model
    else
      @_readAsModel model

  _readAsCollection: (model) ->
    deferred = $.Deferred()

    App.dbCached.getContacts().done (contacts) ->
      contacts = _.filter contacts, (contact) -> contact.status isnt 'DELETED'
      deferred.resolve _.map contacts, (contact) -> _.omit contact, 'status'

    deferred.promise()

  _readAsModel: (model) ->
    deferred = $.Deferred()

    App.dbCached.getContactById(model.id).done (contact) ->
      if _.isNull(contact) or contact.status is 'DELETED'
        deferred.reject NOT_FOUND
      else
        deferred.resolve _.omit contact, 'status'

    deferred.promise()

  update: (model) ->
    deferred = $.Deferred()

    App.dbCached.getContactById(model.id)
      .done (contact) ->
        if contact.status is 'DELETED' then return deferred.reject NOT_FOUND

        data = model.toJSON()
        if contact.status in ['CACHED', 'UPDATED'] then data.status = 'UPDATED'

        App.dbCached.storeContact(data).done ->
          deferred.resolve _.omit data, 'status'

    deferred.promise()

  delete: (model) ->
    deferred = $.Deferred()

    App.dbCached.getContactById(model.id)
      .done (contact) ->
        if contact.status is 'DELETED' then return deferred.reject NOT_FOUND

        data = model.toJSON()

        if contact.status in ['CACHED', 'UPDATED']
          data.status = 'DELETED'
          App.dbCached.storeContact(data).done ->
            deferred.resolve _.omit data, 'status'
        else if contact.status in ['CREATED']
          App.dbCached.deleteContactById(model.id).done ->
            deferred.resolve _.omit data, 'status'

    deferred.promise()

  cacheServerResponse: (resp) ->
    if resp instanceof Array
      for item in resp
        itemToStore = _.clone item # copy to not pollute the resource
        itemToStore.status = 'CACHED'
        App.dbCached.storeContact itemToStore
    else
      itemToStore = _.clone resp # copy to not pollute the resource
      itemToStore.status = 'CACHED'
      App.dbCached.storeContact itemToStore
