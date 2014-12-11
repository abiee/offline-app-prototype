class Contact extends Backbone.Model
  urlRoot: '/contacts'
  idAttribute: '_id'

  defaults:
    name: ''
    phones: []
    emails: []

  countPhones: ->
    if _.isEmpty @get 'phones' then return 0
    @get('phones').length

  countEmails: ->
    if _.isEmpty @get 'emails' then return 0
    @get('emails').length


class ContactCollection extends Backbone.Collection
  url: '/contacts'
  model: Contact
