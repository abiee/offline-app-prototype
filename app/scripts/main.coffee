App = new Backbone.Marionette.Application
App.addRegions
  contactViewerRegion: '#contact-viewer'
  connectionNotifierRegion: '#connection-status'

App.heartbeat = new HeartBeat ->
  App.isOnline = App.heartbeat.isOnline()
  if App.isOnline
    App.trigger 'connection:status', 'online'
    App.connectionNotifierRegion.show new OnlineNotifierView
  else
    App.trigger 'connection:status', 'offline'
    App.connectionNotifierRegion.show new OfflineNotifierView

App.offlineServer = new OfflineServer

App.dbCached = new CachedDatabase()

App.addInitializer ->
  ($ '#new-contact').on 'click', (event) ->
    event.preventDefault()
    controller.createContact()

  contacts = new ContactCollection
  controller = new ContactsAppController contacts: contacts

  contacts.fetch()
  controller.showContactList()

  App.lastStatus = 'offline'
  App.on 'connection:status', (newStatus) ->
    if newStatus is 'online' and App.lastStatus is 'offline'
      App.trigger 'database:sync:start'
      App.offlineServer.syncDatabase().then ->
        App.trigger 'database:sync:done'

    App.lastStatus = newStatus

App.addInitializer ->
  App.offlineServer.syncDatabase()

App.heartbeat.start()
App.once 'connection:status', ->
  App.start()
