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

App.dbCached = new CachedDatabase()

App.addInitializer ->
  App.heartbeat.start()

  ($ '#new-contact').on 'click', (event) ->
    event.preventDefault()
    controller.createContact()

  contacts = new ContactCollection
  controller = new ContactsAppController contacts: contacts

  contacts.fetch()
  controller.showContactList()
