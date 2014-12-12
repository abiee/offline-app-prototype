class ContactsAppController extends Backbone.Marionette.Controller
  initialize: (options) ->
    @contacts = options.contacts

  showContactList: ->
    contactListView = new ContactListView
      el: '#contact-list'
      collection: @contacts

    contactListView.on 'childview:contact:selected', (view, contact) =>
      @showContact contact

    contactListView.render()

  createContact: ->
    contact = new Contact()
    @showEditor contact

  showContact: (contact) ->
    contactDetails = new ContactDetails model: contact
    contactDetails.on 'contact:edit', _.bind @showEditor, @
    contactDetails.on 'contact:delete', (contact) ->
      if confirm 'Sure?'
        contact.destroy
          success: -> App.contactViewerRegion.reset()
          error: -> alert 'Can\'t delete now'
    App.contactViewerRegion.show contactDetails

  showEditor: (contact) ->
    phoneCollection = new Backbone.Collection contact.get 'phones'
    emailCollection = new Backbone.Collection contact.get 'emails'

    editorLayout = new ContactEditorLayout
    contactEditorGeneral = new ContactEditorGeneral model: contact
    phoneCollectionEditor = new PhoneCollectionEditor collection: phoneCollection
    emailCollectionEditor = new EmailCollectionEditor collection: emailCollection

    editorLayout.on 'edit:cancel', => @showContact contact
    editorLayout.on 'edit:save', =>
      contact.set 'name', contactEditorGeneral.ui.name.val()
      contact.set 'phones', phoneCollection.toJSON()
      contact.set 'emails', emailCollection.toJSON()
      contact.save null,
        success: =>
          if not @contacts.get contact then @contacts.add contact
          @showContact contact
        error: ->
          alert 'Oops... Can\'t save contact'
    editorLayout.on 'phones:new', -> phoneCollection.add
      description: ''
      number: ''
    editorLayout.on 'emails:new', -> emailCollection.add
      description: ''
      email: ''
    phoneCollectionEditor.on 'childview:phone:delete', (view) ->
      phoneCollection.remove view.model
    emailCollectionEditor.on 'childview:email:delete', (view) ->
      emailCollection.remove view.model

    App.contactViewerRegion.show editorLayout
    editorLayout.generalRegion.show contactEditorGeneral
    editorLayout.phonesRegion.show phoneCollectionEditor
    editorLayout.emailsRegion.show emailCollectionEditor

