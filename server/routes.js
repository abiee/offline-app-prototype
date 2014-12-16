var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var ContactSchema = new Schema({
    name: String,
    phones: [{
        description: String,
        number: String
    }],
    emails: [{
        description: String,
        email: String
    }],
    syncId: String
});
var Contact = mongoose.model('Contact', ContactSchema);

mongoose.connect('mongodb://localhost/contacts');

function handleDatabaseError(req, res, err) {
    res.status(500).json({
        message: 'Database error',
        details: err
    })
}

function createContact(req, res) {
    var contactData = req.body;

    function createContact(contactData) {
        var contact = new Contact(contactData);
        contact.save(function (err) {
            if (err) {
                handleDatabaseError(req, res, err);
            } else {
                res.json(contact);
            }
        });
    }

    if (contactData.syncId !== '') {
        createContact(contactData);
    } else {
      Contact.findOne({ syncId: contactData.syncId }, function (err, contact) {
          if (err) {
              handleDatabaseError(req, res, err);
          } else if (contact) {
            res.json(contact)
          } else {
            createContact(contactData);
          }
      })
    }
}

function showContactList(req, res) {
    Contact.find().sort('name').exec(function (err, contacts) {
        if (err) {
            handleDatabaseError(req, res, err);
        } else {
            res.json(contacts);
        }
    });
}

function showContact(req, res) {
    var contactId = req.params.id;
    Contact.findOne({ _id: contactId }, function (err, contact) {
        if (err) {
            handleDatabaseError(req, res, err);
        } else {
            if (contact) {
                res.json(contact);
            } else {
                res.status(404).json({ message: 'Contact not found' })
            }
        }
    });
}

function editContact(req, res) {
    var contactId = req.params.id;
    var contactData = req.body;
    Contact.findOne({ _id: contactId }, function (err, contact) {
        if (err) {
            handleDatabaseError(req, res, err);
        } else {
            if (contact) {
                contact.set(contactData);
                contact.save(function(err) {
                  res.json(contact);
                })
            } else {
                res.status(404).json({ message: 'Contact not found' })
            }
        }
    });
}

function deleteContact(req, res) {
    var contactId = req.params.id;
    Contact.findOneAndRemove({ _id: contactId }, function (err, contact) {
        if (err) {
            handleDatabaseError(req, res, err);
        } else {
            if (contact) {
                res.json(contact);
            } else {
                res.status(404).json({ message: 'Contact not found' });
            }
        }
    })
}

function respondPing(req, res) {
  res.send('pong');
}

module.exports = function (app) {
    app.get('/api/contacts', showContactList);
    app.get('/api/contacts/:id', showContact);
    app.post('/api/contacts', createContact);
    app.put('/api/contacts/:id', editContact);
    app.delete('/api/contacts/:id', deleteContact);
    app.get('/api/ping', respondPing);
}
