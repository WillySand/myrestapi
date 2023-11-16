const express = require('express');
const mysql = require('mysql2');
const app = express();
const port = 8000;

// Create a connection pool
const pool = mysql.createPool({
  host: 'localhost',
  port: 3306,  // Change this to your MySQL port
  user: 'root',
  password: '2082',
  database: 'mydb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Middleware for parsing JSON
app.use(express.json());


// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Example route using the database connection
app.get('/restos', (req, res) => {
  // Your SQL query
  const sqlQuery = `
    SELECT
        *
    FROM
        mydb.Resto
  `;
  // Execute the SQL query
  pool.query(sqlQuery, (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});


app.get('/restos/:idResto', (req, res) => {
  const idResto = req.params.idResto;
  if (!/^\d+$/.test(idResto)) {// Check if idResto contain only numbers
    return res.status(400).json({ error: 'Invalid idResto parameter' });
  } 
  const sqlQuery = `
    SELECT
        *
    FROM
        mydb.Resto
    WHERE
        mydb.Resto.idResto = ?
  `;
  // Execute the SQL query
  pool.query(sqlQuery, [idResto], (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.get('/menus', (req, res) => {

  const sqlQuery = `
    SELECT
        mydb.Menu.*
    FROM
        mydb.Menu
  `;
  // Execute the SQL query
  pool.query(sqlQuery, (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.get('/menus/available', (req, res) => {

  const sqlQuery = `
    SELECT
        mydb.Menu.*
    FROM
        mydb.Menu
    WHERE
        mydb.Menu.availability > 0
  `;
  // Execute the SQL query
  pool.query(sqlQuery, (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.get('/menus/:idResto', (req, res) => {
  const idResto = req.params.idResto;
  if (!/^\d+$/.test(idResto)) {// Check if idResto contain only numbers
    return res.status(400).json({ error: 'Invalid idResto parameter' });
  } 
  const sqlQuery = `
    SELECT
        mydb.Menu.*
    FROM
        mydb.Menu
    WHERE
        mydb.Menu.idResto = ?
  `;
  pool.query(sqlQuery, [idResto], (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});
app.get('/menus/available/:idResto', (req, res) => {

  const idResto = req.params.idResto;
  if (!/^\d+$/.test(idResto)) {// Check if idResto contain only numbers
    return res.status(400).json({ error: 'Invalid idResto parameter' });
  } 
  const sqlQuery = `
    SELECT
        mydb.Menu.*
    FROM
        mydb.Menu
    WHERE
        mydb.Menu.idResto = ? AND
        mydb.Menu.availability > 0
  `;
  // Execute the SQL query
  pool.query(sqlQuery, [idResto], (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.post('/addToCart', (req, res) => {
  const idMenu = req.body.idMenu;
  const idCart = req.body.idCart;
  const quantity = req.body.quantity;
  if (!/^\d+$/.test(idMenu) && !/^\d+$/.test(idCart) && !/^\d+$/.test(quantity) ) {// Check if idResto and quantity contain only numbers
    return res.status(400).json({ error: 'Invalid idMenu, idCart, or quantity parameter' });
  } 
  
  const sqlQuery = `
  CALL AddToCart(${idMenu}, ${quantity}, ${idCart});
  `;
  // Execute the SQL query
  pool.query(sqlQuery, (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.put('/modifyCart', (req, res) => {
  const idCartItem = req.body.idCartItem;
  const idMenu = req.body.idMenu;
  const quantity = req.body.quantity;
  let sqlQuery;
  if (idCartItem === undefined || !/^\d+$/.test(idCartItem)){
    return res.status(400).json({ error: 'idCartItem Invalid'});
  } 
  else {
    if (idMenu === undefined && /^\d+$/.test(quantity)){
      sqlQuery = `
      CALL EditCartQuantity(${quantity}, ${idCartItem});
      `;
    }
    else if(quantity === undefined && /^\d+$/.test(idMenu)){
      sqlQuery = `
      CALL EditCartMenu(${idMenu}, ${idCartItem});
      `;
    }
    else if(/^\d+$/.test(idMenu) && /^\d+$/.test(quantity)){
      sqlQuery = `
      CALL EditCart(${idMenu}, ${quantity}, ${idCartItem});
      `;
    }
    else{
      return res.status(400).json({ error: 'quantity / menu invalid'});  
    }
  }

    pool.query(sqlQuery, (error, results, fields) => {
      if (error) {
        console.error('Error executing the query:', error);
        res.status(500).json({ error: 'Internal Server Error' });
      } else {
        // Send the query results as JSON
        res.json(results);
      }
    });
  });

app.delete('/removeCart', (req, res) => {
  const idCartItem = req.body.idCartItem;
  const sqlQuery = `
  DELETE FROM mydb.CartItem CI
  WHERE CI.idCartItem = ?;
  `;
  pool.query(sqlQuery, [idCartItem], (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.post('/checkout', (req, res) => {
  const idCart = req.body.idCart;
  const sqlQuery = `
  CALL CheckoutCart(?);
  `;
  pool.query(sqlQuery, [idCart], (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.post('/checkoutWithRemoval', (req, res) => {
  const idCart = req.body.idCart;
  const sqlQuery = `
  CALL CheckoutCartWithRemoval(?);
  `;
  pool.query(sqlQuery, [idCart], (error, results, fields) => {
    if (error) {
      console.error('Error executing the query:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    } else {
      // Send the query results as JSON
      res.json(results);
    }
  });
});

app.use(express.json());