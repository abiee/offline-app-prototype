class ContactEditorLayout extends Backbone.Marionette.LayoutView
  template: '#contact-editor-layout'

  regions:
    generalRegion: '#general-contact-data'
    phonesRegion: '#phone-list'
    emailsRegion: '#email-list'

  triggers:
    'click #cancel-edit': 'edit:cancel'
    'click #save-contact': 'edit:save'
    'click #new-phone': 'phones:new'
    'click #new-email': 'emails:new'


class ContactEditorGeneral extends Backbone.Marionette.ItemView
  template: '#contact-editor-general'

  ui:
    name: 'input#name'


class PhoneItemEditor extends Backbone.Marionette.ItemView
  template: '#contact-editor-phone'

  triggers:
    'click #delete-phone': 'phone:delete'

  onRender: ->
    (@$ '.description').editable
      success: (response, newValue) =>
        @model.set 'description', newValue

    (@$ '.number').editable
      success: (response, newValue) =>
        @model.set 'number', newValue


class PhoneCollectionEditor extends Backbone.Marionette.CollectionView
  childView: PhoneItemEditor


class EmailItemEditor extends Backbone.Marionette.ItemView
  template: '#contact-editor-email'

  triggers:
    'click #delete-email': 'email:delete'

  onRender: ->
    (@$ '.description').editable
      success: (response, newValue) =>
        @model.set 'description', newValue

    (@$ '.email').editable
      success: (response, newValue) =>
        @model.set 'email', newValue


class EmailCollectionEditor extends Backbone.Marionette.CollectionView
  childView: EmailItemEditor
