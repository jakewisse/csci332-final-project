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

// Object to store state (i.e. session, but really simple)
var mysession = {
	user: ''
}

//
function checkAuth(req, res, next) {
	if (!req.cookies.user) {
		mysession.user = '';
		next();
	}
	else {
		mysession.user = req.cookies.user;
		next();
	}
}

var app = express();
app.use(express.bodyParser()); // for POST requests
app.use(express.cookieParser('notasecret')); // for signing cookies
app.engine('html', require('ejs').__express); // for using the ejs templating engine
app.listen(8080);

// Set views directory
app.set('views', __dirname + '/views');


// Serve static files
app.use(express.static(__dirname + '/static'));


// Serve index.html
app.get('/', function(req, res) {
	res.render('index.html');
});


// signup.html
app.get('/signup.html', function(req, res) {
	res.render('signup.html');
});


// Create new account
app.post('/createAccount', function (req, res) {

	// Create an object with the request body's params
	var post = 
	{
		'email': req.body.email,
		'FirstName': req.body.firstName,
		'LastName': req.body.lastName,
		'Phone': req.body.phone,
		'Password': req.body.password
	};

	// TODO: Execute stored procedure to insert new user

	res.cookie('user', post.email)
	res.json(post)

	// TODO: Redirect user to makeReservation.html
	

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


