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
    //'multipleStatements': true
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

// Set EJS's views directory
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


// Request to create a new user
//
// Uses the insertNewUser() stored procedure.  If user email
// is already in the db, the second query will return 1,
// if success, 0.
app.post('/createAccount', function (req, res) {

    // Create an object with the request body's params
    var sqlParams = 
    [
        req.body.email,
        req.body.password,
        req.body.firstName,
        req.body.lastName,
        req.body.phone
    ];

    var sql = 'CALL insertNewUser(' + connection.escape(sqlParams) + ');';


    // TODO: Execute stored procedure to insert new user
    var query = connection.query(sql, function (err, results) {
        if (err.code == 'ER_DUP_ENTRY')
            res.json({success: false, dup: true});
        else if (err)
            res.json({success: false, dup: false});
        else
            res.json({success: true, dup: false});
    });

    // TODO: Set user cookie

    // TODO: Redirect user
    

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


