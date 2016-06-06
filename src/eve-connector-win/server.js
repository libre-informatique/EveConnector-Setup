var fs = require('fs');
var https_options = {
    key: fs.readFileSync(__dirname + '/node_modules/eve-connector/server.key'),
    cert: fs.readFileSync(__dirname + "/node_modules/eve-connector/server.crt")
}

//console.log(https_options);

var EC = require(__dirname + '/node_modules/eve-connector/eve-connector-server.js').createServer(8164, https_options);
