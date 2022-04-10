var rc522 = require("rc522-empty-card");

console.log('Ready!!!');

rc522(function(rfidSerialNumber){
	console.log(rfidSerialNumber);
}, function() {
	console.log('no card');
});

