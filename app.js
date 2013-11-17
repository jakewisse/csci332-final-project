// Charleston Paddler Web Application
// 
// Author: Jake Wisse
// Github Repo: https://github.com/jakewisse/csci332-final-project

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


function checkAuth(req, res, next) {

    // User is not logged in
    if (!req.session) {
        res.send("You are not logged in!");
    }

    // User is logged in
    else 
        next();
}

var app = express();
app.use(express.bodyParser()); // for POST requests
app.use(express.cookieParser('notasecret')); // for signing cookies
app.use(express.cookieSession('notasecret'));
app.engine('html', require('ejs').__express); // for using the ejs templating engine
app.listen(8080);

// Set EJS's views directory
app.set('views', __dirname + '/views');


// Serve static files
app.use(express.static(__dirname + '/static'));


// Serve index.html
app.get('/', function(req, res) {
    res.render('index.html', {session: req.session});
    console.log(req.session);
});

app.get('/logout', function(req, res) {
    req.session.user = null;
    res.render('index.html', {session: req.session});
});


// signup.html
app.get('/signup.html', function(req, res) {
    res.render('signup.html');
});

// reservation.html
app.get('/reservation.html', checkAuth, function(req, res) {
    res.clearCookie('user');
    res.render('reservation.html');
});

// Request to login
//
app.post('/login', function(req, res) {
    var sqlParams = [req.body.email, req.body.password];

    var sql = 'CALL checkPassword(' + connection.escape(sqlParams) + ');';

    connection.query(sql, function(err, results) {
        
        if (!err) {
     
            if (results[0][0].auth == true) {
                // User is authenticated
                res.json({auth: true, msg: ''});
            } else {
                res.json({auth: false, msg: 'Incorrect password!'});
            }
        } else {
            if (err.sqlState == '02000')
                res.json({auth: false, msg: 'Sorry, no user exists with that email address.'});
            else {
                res.json({auth: false, msg: 'SQL ERROR.\nerr.code: ' + err.code +
                                            '\nerr.errno: ' + err.errno +
                                            '\nerr.sqlState ' + err.sqlState});
            }
        }

    });


});




// Request to create a new user
//
// Uses the insertNewUser() stored procedure.  We watch for ER_DUP_ENTRY
// SQL error specifically.
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

    var query = connection.query(sql, function (err, results) {

        // Success
        if (!err) {
            req.session.user = {
                email: req.body.email,
                firstName: req.body.firstName,
                lastName: req.body.lastName
            }

            res.json({success: true, msg: ''});
        }

        // Duplicate
        else if (err.code == 'ER_DUP_ENTRY')
            res.json({success: false, msg: 'A user already exists with this email!'});

        // Other error
        else {
            res.json({success: false,
                      msg: 'Error inserting new user.\nSQL error code: ' + err.code});
        }
    });
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


