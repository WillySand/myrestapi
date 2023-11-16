Run MYSQL Server on port 3306 by running 'CreateDB.sql' and 'PopulateDB.sql' (There is also a generated dump 'exported.sql')
Run app.js

Queries : 
GET /restos
	- Returns all restos
GET /restos/:idResto
	- Returns resto with specific idResto
GET /menus
	- Returns all menus
GET /menus/:idResto
	- Returns all menus of a specific resto
GET /menus/available
	- Returns all menus with availability that is not zero
GET /menus/available/:idResto
	- Returns all menus of a specific resto with availability that is not zero
POST /addToCart
	- Expect idMenu, idCart, and quantity in the POST request body
	- Add CartItem to Cart if availability > quantity
	- Update CartItem if availability > quantity + old quantity if there is already a Cartitem in Cart with the same idMenu
PUT /modifyCart
	- Expect idCart & idMenu and/or quantity in request body
	- Update CartItem with the new idMemu and/or quantity
	- Fails if quantity is higher than availability
DELETE /removeCart
	- Expect idCartItem in request body
	- Removes item from cart
POST /checkout
	- Expect idCart in request body
	- Returns all item in the cart that has higher availability than quantity in Cart and show total price 
POST /checkout
	- Expect idCart in request body
	- Returns all item in the cart that has higher availability than quantity in Cart and show total price 
	- Reduces availability in Menu
	- Removes Cart and CartItem specified by idCart




	
