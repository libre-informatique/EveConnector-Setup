var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
  name:'EveConnector',
  description: 'USB over WebSockets service',
  script: require('path').join(__dirname,'server.js')
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install', function(){
  console.log('EveConnector service installed')
  svc.start();
});

// Fired in some instances when an error occurs
svc.on('error', function(){
  console.log('EveConnector service : an error occurred')
  svc.start();
});

// Fired if an installation is detected but missing required files
svc.on('invalidinstallation', function(){
  console.log('EveConnector service : an error occurred')
  svc.start();
});

// Listen for the "start" event.
svc.on('start',function(){
  console.log('EveConnector service started')
});

// Listen for the "stop" event.
svc.on('stop',function(){
  console.log('EveConnector service stopped')
});

// Fired when an uninstallation is complete
svc.on('uninstall',function(){
  console.log('EveConnector service uninstalled')
});


var uninstall = process.argv.some(function (val) {
  return val === 'uninstall';
});
var stop = process.argv.some(function (val) {
  return val === 'stop';
});

if ( uninstall ) {
  if ( svc.exists ) svc.uninstall();
  else console.log('EveConnector service does not exist')
}
else if ( stop ) {
  if ( svc.exists ) svc.stop();
  else console.log('EveConnector service does not exist')
}
else if ( svc.exists ) svc.start();
else svc.install();
