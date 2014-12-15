class CachedDatabase
  storeContact: (contact) ->
    @_connect()
      .done (db) ->
        transaction = db.transaction 'contacts', 'readwrite'
        store = transaction.objectStore 'contacts'
        request = store.put contact
        request.onsuccess = ->
        request.onerror = ->
          console.log 'Error saving', contact
        contact
      .fail ->
        console.log 'Can not connect to database'

  getContacts: ->
    deferred = $.Deferred()
    result = []

    @_connect()
      .done (db) ->
        transaction = db.transaction 'contacts', 'readonly'
        store = transaction.objectStore 'contacts'
        index = store.index 'by_name'
        request = store.openCursor()
        request.onsuccess = ->
          if request.result
            cursor = request.result
            result.push cursor.value
            cursor.continue()
          else
            deferred.resolve result
    deferred.promise()

  getContactById: (id) ->
    deferred = $.Deferred()

    @_connect()
      .done (db) ->
        transaction = db.transaction 'contacts', 'readonly'
        store = transaction.objectStore 'contacts'
        request =store.get id
        request.onsuccess = ->
          if not _.isUndefined request.result
            deferred.resolve request.result
          else
            deferred.resolve(null)
    deferred.promise()

  getContactsByStatus: (status) ->
    deferred = $.Deferred()
    result = []

    @_connect()
      .done (db) ->
        transaction = db.transaction 'contacts', 'readonly'
        store = transaction.objectStore 'contacts'
        index = store.index 'by_status'
        request = index.openCursor(IDBKeyRange.only(status))
        request.onsuccess = ->
          if request.result
            cursor = request.result
            result.push cursor.value
            cursor.continue()
          else
            deferred.resolve result

    deferred.promise()

  deleteContactById: (id) ->
    deferred = $.Deferred()

    @_connect()
      .done (db) ->
        transaction = db.transaction 'contacts', 'readwrite'
        store = transaction.objectStore 'contacts'
        request = store.delete id
        request.onsuccess = ->
          deferred.resolve()
        request.onerror = ->
          deferred.reject()
    deferred.promise()

  _connect: ->
    deferred = $.Deferred()

    if @database then return deferred.resolve @database

    request = indexedDB.open 'agroniaco_cache', 1

    request.onsuccess = (evt) =>
      @database = evt.target.result
      deferred.resolve @database
    request.onerror = (evt) ->
      deferred.reject()
    request.onupgradeneeded = => @_createDatabase request

    deferred.promise()

  _createDatabase: (request) ->
    db = request.result
    store = db.createObjectStore 'contacts', { keyPath: '_id' }
    nameIndex = store.createIndex 'by_name', 'name'
    statusIndex = store.createIndex 'by_status', 'status'
