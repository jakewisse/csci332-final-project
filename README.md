Final Project for CSCI 332 - Databases
======================================

This is my final project for CSCI 332 at the College of Charleston.  It is a web application for a [sort of] imaginary eco-tours business called the Charleston Paddler.  Here's a living list of functional requirements for this app:

+ Allow customers to create an account, using their email address as a password.
+ Allow customers to make a reservation for a tour, selecting a currently open time slot.

#### How to install and deploy

Clone the repo:

    git clone https://github.com/jakewisse/csci332-final-project.git

Configure a MySQL instance and execute the SQL script `sql/generateSchema.sql`.

Create the necessary stored procedures by executing `sql/createProcedures.sql`.

Change the code in lines 17-24 of `app.js` where the MySQL connection is defined:

```javascript
// Initialize MySQL connection and web server
var connection = mysql.createConnection({
    'host': 'YOUR_HOSTNAME',
    'port': YOUR_MYSQL_PORT,
    'user': 'YOUR_USERNAME',
    'password': 'YOUR_PASSWORD',
    'database': 'ChsPaddler',
    'multipleStatements': true
});
```

Change the port which the app listens on to 80, or whatever you would like on line 33 of `app.js`:

```javascript
app.listen(PORT_OF_YOUR_CHOOSING);
```

At this point, the app should work just fine, but it might be a little boring because there are no tours or guides in the database.  I was planning on implementing an admin console where guides and tours could be added, but I ran out of time.  So instead just open up a SQL query and execute:

```sql
CALL initTourAndGuideTables();
```

And that's it!  You can now start the app by running `node app.js`.