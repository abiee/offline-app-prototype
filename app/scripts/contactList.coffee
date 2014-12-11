class ContactListItemView extends Backbone.Marionette.ItemView
  tagName: 'a'
  className: 'list-group-item'
  template: '#contact-list-item'
  modelEvents:
    'change': 'render'

  onRender: -> @$el.attr 'href', '#'

  serializeData: ->
    serializedData = @model.toJSON()

    if _.isEmpty @model.get 'name'
      serializedData['name'] = '(In blank)'

    serializedData['phoneCount'] = @model.countPhones()
    serializedData['emailCount'] = @model.countEmails()

    serializedData

  events:
    'click': 'showContact'

  showContact: (event) ->
    event.preventDefault()
    @trigger 'contact:selected', @model


class ContactListView extends Backbone.Marionette.CollectionView
  childView: ContactListItemView

  childEvents:
    'contact:selected': (view, contact) ->
      @clearSelection()
      @selectContact contact

  clearSelection: ->
    @$('.list-group-item.active').removeClass 'active'

  selectContact: (contact) ->
    targetView = @children.findByModel contact
    if targetView then targetView.$el.addClass 'active'
