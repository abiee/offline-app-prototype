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

  syncDatabase: ->
    $.when App.dbCached.getContactsByStatus('CREATED'), \
           App.dbCached.getContactsByStatus('UPDATED'), \
           App.dbCached.getContactsByStatus('DELETED')
      .done (created, updated, deleted) =>
        @_chainAjaxRequests(created)
          .then =>
            @_chainAjaxRequests(updated)
          .then =>
            @_chainAjaxRequests(deleted)

  _chainAjaxRequests: (items, i=0) ->
    deferred = $.Deferred()

    if i >= items.length then return deferred.resolve()

    item = items[i]
    @_doCachedAction(item).then =>
      @_chainAjaxRequests items, i + 1
    .fail ->
      deferred.reject()

  _doCachedAction: (data) ->
    if data.status is 'CREATED'
      @_createResourceFromCache _.omit data, 'status'
    else if data.status is 'UPDATED'
      @_updateResourceFromCache _.omit data, 'status'
    else if data.status is 'DELETED'
      @_deleteResourceFromCache _.omit data, 'status'

  _createResourceFromCache: (data) ->
    deferred = $.Deferred()

    data = _.clone data
    data.syncId = data._id

    $.ajax
      url: '/api/contacts/'
      type: 'POST'
      contentType: 'application/json'
      data: JSON.stringify _.omit data, '_id'
    .then (resp) =>
      App.dbCached.deleteContactById(data._id).then =>
        @cacheServerResponse resp
        deferred.resolve()
      .fail ->
        deferred.reject()
    .fail ->
      deferred.reject()

    deferred.promise()

  _updateResourceFromCache: (data) ->
    $.ajax
      url: "/api/contacts/#{data._id}"
      type: 'PUT'
      contentType: 'application/json'
      data: JSON.stringify data
    .then (resp) =>
      @cacheServerResponse resp

  _deleteResourceFromCache: (data) ->
    deferred = $.Deferred()

    $.ajax
      url: "/api/contacts/#{data._id}"
      type: 'DELETE'
      contentType: 'application/json'
    .then (resp) =>
      App.dbCached.deleteContactById(data._id).then ->
        deferred.resolve()
      .fail ->
        deferred.reject()
    .fail (xhr) ->
      if xhr.status is 404
        App.dbCached.deleteContactById(data._id).then ->
          deferred.resolve()
      else
        deferred.reject()
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
