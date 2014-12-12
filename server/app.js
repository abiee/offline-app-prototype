var express = require('express'),
    compression = require('compression'),
    bodyParser = require('body-parser'),
    http = require('http');

app = express();

app.use(compression());
app.use(bodyParser.json())

if(process.env.NODE_ENV === 'production') {
  app.use(express.static(__dirname + '/../dist'));
} else {
  app.use(express.static(__dirname + '/../app'));
}

app.use('/bower_components', express.static(__dirname + '/../bower_components'));
app.use(express.static(__dirname + '/../.tmp'));

require('./routes')(app);

app.set('port', process.env.PORT || 3000);
http.createServer(app).listen(app.get('port'), '0.0.0.0', function() {
    console.log('App started on port', app.get('port'));
});
