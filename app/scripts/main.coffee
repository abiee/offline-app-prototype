App = new Backbone.Marionette.Application
App.addRegions
  contactViewerRegion: '#contact-viewer'

App.heartbeat = new HeartBeat

App.addInitializer ->
  App.heartbeat.start()

  App.heartbeat.checkServerAvailability().done ->
    console.log 'is online?', App.heartbeat.isOnline()
  setInterval ->
    console.log 'is online?', App.heartbeat.isOnline()
  , 5000

  ($ '#new-contact').on 'click', (event) ->
    event.preventDefault()
    controller.createContact()

  contacts = new ContactCollection
  controller = new ContactsAppController contacts: contacts

  contacts.fetch()
  controller.showContactList()
