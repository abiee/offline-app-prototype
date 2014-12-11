class ContactDetails extends Backbone.Marionette.ItemView
  template: '#contact-details'

  events:
    'click #edit-contact': 'editContact'
    'click #delete-contact': 'deleteContact'

  serializeData: ->
    serializedData = @model.toJSON()

    if _.isEmpty @model.get 'name'
      serializedData['name'] = '(In blank)'

    serializedData['phoneCount'] = @model.countPhones()
    serializedData['emailCount'] = @model.countEmails()

    serializedData

  editContact: ->
    @trigger 'contact:edit', @model

  deleteContact: ->
    @trigger 'contact:delete', @model
