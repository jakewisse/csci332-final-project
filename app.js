/**
 * Charleston Paddler Web Application
 *
 * Author: Jake Wisse
 * Github Repo: https://github.com/jakewisse/csci332-final-project
 * 
 */


// Modules
var express = require('express'),
    mysql = require('mysql');

var app = express();

// Initialize MySQL connection and web server
var connection = mysql.createConnection({
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'root',
    'database': 'ChsPaddler',
    'multipleStatements': true
});

// Express.js Middleware
app.use(express.bodyParser()); // for POST requests
app.use(express.cookieParser('notasecret')); // for signing cookies
app.use(express.cookieSession('notasecret'));
app.engine('html', require('ejs').__express); // for using the EJS templating engine
app.set('views', __dirname + '/views'); // Set EJS's views directory

app.listen(8080);


//  TODO: Needs to be adapted...
function checkAuth(req, res, next) {

    // User is not logged in
    if (!req.session) {
        res.send("You are not logged in!");
    }

    // User is logged in
    else 
        next();
}


/*
 * ------  HTTP request handlers --------
 */

// Serve static files
app.use(express.static(__dirname + '/static'));


// Serve index.html
app.get('/', function(req, res) {
    var vars = {};

    // Don't query the db if the user isn't logged in
    if (req.session.user) {
        connection.query('CALL selectResByUser(?);', req.session.user.email,
            function(err, results) {
                if (!err) {
                    var reservations = results[0];
                    res.render('index.html', {session: req.session, 'reservations': reservations});
                }
                else {
                    console.log(err);
                    res.render('index.html', {session: req.session});
                }
            });

    } else {
        res.render('index.html', {session: req.session});
    }

});

// Login
app.post('/login', function(req, res) {

    var sqlParams = [req.body.email, req.body.password];

    var sql = 'CALL checkPassword(' + connection.escape(sqlParams) + ');';

    connection.query(sql, function(err, results) {
        if (!err) {
            if (results[0][0].auth == 'true') {
                // User is authenticated
                req.session.user = {
                    email: req.body.email
                }
                res.json({auth: true, msg: ''});
            } else {
                res.json({auth: false, msg: 'Incorrect password!'});
            }
        } else {
            if (err.sqlState == '02000')
                res.json({auth: false, msg: 'Sorry, no user exists with that email address.'});
            else {
                res.json({auth: false,
                          msg: 'SQL ERROR.\nerr.code: ' + err.code +
                               '\nerr.errno: ' + err.errno +
                               '\nerr.sqlState ' + err.sqlState
                         });
    }
        }
    });
});

// Logout
app.get('/logout', function(req, res) {
    req.session.user = null;
    res.redirect('/');
});

// signup.html
app.get('/signup.html', function(req, res) {
    res.render('signup.html');
});

// reservation.html
app.get('/reservation.html', function(req, res) {

    connection.query('CALL availableTours();', function (err, results) {
        if (err) {
            console.log(err);
            res.redirect('/');
        } else {
            res.render('reservation.html', {session: req.session, availTours: results[0]});
        }
    })
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
                email: req.body.email
                // Possible to store more session state here
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

    var sqlParams =
        {
            'GroupSize': req.body.groupSize,
            'User_Email': req.session.user.email,
            'Tour_idTour': req.body.idTour
        };


    connection.query('INSERT INTO Reservation SET ?', sqlParams, 
        function (err, result) {
            if (err) {
                console.log(err);
                res.json({
                    'status': "ERROR",
                    'error': err
                });
            }
            else {
                res.json({
                    'status': 'OK',
                    'error': null
                });
            }
        }
    );
});


// Check to see what tours are available
app.post('/availableTours', function (req, res) {

    var q = connection.query('CALL availableTours()', function (err, results) {
        if (err)
            console.log(err);
        else {
            res.json(results);
        }
    })
});


app.post('/availableToursByDate', function (req, res) {

    var d = new Date(req.body.d);

    connection.query('CALL availTourInfoByDate(\'' + d.format('yyyy-MM-dd') + '\');',
        function (err, results) {
            if (err) {
                console.log(err);
            }
            else {
                res.json(results[0]);
            }
        })
})





// Date formatting
Date.prototype.format = function (format) //author: meizz
{
    var hours = this.getHours();
    var ttime = "AM";
    if(format.indexOf("t") > -1 && hours > 12)
    {
        hours = hours - 12;
        ttime = "PM";
    }

    var o = {
        "M+": this.getMonth() + 1, //month
        "d+": this.getDate(),    //day
        "h+": hours,   //hour
        "m+": this.getMinutes(), //minute
        "s+": this.getSeconds(), //second
        "q+": Math.floor((this.getMonth() + 3) / 3),  //quarter
        "S": this.getMilliseconds(), //millisecond,
        "t+": ttime
    }

    if (/(y+)/.test(format)) format = format.replace(RegExp.$1,
      (this.getFullYear() + "").substr(4 - RegExp.$1.length));
        for (var k in o) if (new RegExp("(" + k + ")").test(format))
            format = format.replace(RegExp.$1,
              RegExp.$1.length == 1 ? o[k] :
              ("00" + o[k]).substr(("" + o[k]).length));
        return format;
}



