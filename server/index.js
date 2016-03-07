
// compatible API routes.
var express        = require('express'),
    path           = require('path'),
    mongoose       = require('mongoose'),
    logger         = require('morgan'),
    bodyParser     = require('body-parser'),
    compress       = require('compression'),
    favicon        = require('static-favicon'),
    methodOverride = require('method-override'),
    errorHandler   = require('errorhandler'),
    config         = require('../config'),
    routes         = require('../routes');

var ParseServer = require('parse-server').ParseServer;

var databaseUri = process.env.DATABASE_URI || process.env.MONGOLAB_URI;

if (!databaseUri) {
  console.log('DATABASE_URI not specified, falling back to localhost.');
}

var api = new ParseServer({
  databaseURI: databaseUri || 'mongodb://127.0.0.1:27017/dev',
  cloud: process.env.CLOUD_CODE_MAIN || __dirname + '/../cloud/main.js',
  appId: process.env.APP_ID || 'fake_app',
  javascriptKey: 'javascriptKey',
  masterKey: process.env.MASTER_KEY || 'master_key', //Add your master key here. Keep it secret!
  serverURL: process.env.SERVER_URL || 'http://localhost:1337/parse'  // Don't forget to change to https if needed
});
// Client-keys like the javascript key or the .NET key are not necessary with parse-server
// If you wish you require them, you can set them as options in the initialization above:
// javascriptKey, restAPIKey, dotNetKey, clientKey

var app = express();
app
  .use(compress())
  .use(favicon())
  .use(logger('dev'))
  .use(bodyParser())
  .use(methodOverride())
  .use(express.static(path.join(__dirname, '../public')))
  .use(routes.indexRouter);

// Serve the Parse API on the /parse URL prefix
var mountPath = process.env.PARSE_MOUNT || '/parse';
app.use(mountPath, api);

// Parse Server plays nicely with the rest of your web routes
app.get('/', function(req, res) {
  res.status(200).send('I dream of being a web site.');
});

app.set('port', config.server.port);
app.set('views', path.join(__dirname, 'views'));
// app.set('view engine', 'jade');



if (app.get('env') === 'development') {
  app.use(errorHandler());
}

var port = process.env.PORT || 1337;
app.listen(port, function() {
    console.log('parse-server-example running on port ' + port + '.');
});
