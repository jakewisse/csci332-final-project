// Charleston Paddler Web Application
// 
// Author: Jake Wisse

// Modules
var express = require('express'),
	mysql = require('mysql');

// Initialize MySQL connection and web server
var connection = mysql.createConnection({
	'host': 'localhost',
	'port': 3306,
	'user': 'root',
	'password': 'root',
	'database': 'ChsPaddler'
});

var app = express();
app.use(express.bodyParser());
app.listen(8080);


// Serve static files
app.use(express.static(__dirname + '/static'));

// Serve index.html
app.get('/', function(req, res) {
	res.sendfile(__dirname + '/index.html');
});


// Add Reservation to DB
app.post('/addReservation', function (req, res) {
	var post =
	{
		'Phone': req.body.phone,
		'Email': req.body.email,
		'FirstName': req.body.firstName,
		'LastName': req.body.lastName,
		'Email': req.body.email
	};
    connection.query('INSERT INTO Reservation SET ?', post, 
        function (err, result) {
            if (err) throw err;
            res.json({
            	'status': 'OK',
            	'id': result.insertId
            });
        }
    );
});


