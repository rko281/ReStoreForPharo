# What is ReStore?
ReStore is a framework enabling Pharo objects to be stored in and read from relational databases (SQLite, PostgreSQL etc.). ReStore aims to make relational persistency as simple as possible, creating and maintaining the database structure itself and providing access to stored objects via familiar Smalltalk messages. 

# Getting Started 
To load ReStore into your Pharo 8 or 9 image, evaluate:

```smalltalk
Metacello new
    repository: 'github://rko281/ReStoreForPharo';
    baseline: 'ReStore';
    load: 'all'
```

This will load ReStore with support for SQLite and MySQL (via [pharo-rdbms](https://github.com/pharo-rdbms/Pharo-SQLite3)), PostgreSQL (via [P3](https://github.com/svenvc/P3)), plus the example classes we'll discuss next.

# A Simple Example
Let's consider a simple customer order application with the following classes (found in the `SSW ReStore Examples` package):

```smalltalk
Object subclass: #Customer
	instanceVariableNames: 'firstName surname emailAddress dateOfBirth address orders'

Object subclass: #CustomerOrder
	instanceVariableNames: 'orderDate customer items totalPrice'
	
Object subclass: #CustomerOrderItem
	instanceVariableNames: 'order product quantity'
    
Object subclass: #Product
	instanceVariableNames: 'name description price'
```

The first step in adding persistency with ReStore is to define the structure of the classes. This is done with the class method reStoreDefinition - for the Customer class this is:

```smalltalk
reStoreDefinition

	^super reStoreDefinition
		define: #surname as: (String maxSize: 100);
		define: #firstName as: (String maxSize: 100);
		define: #emailAddress as: (String maxSize: 100);
		define: #dateOfBirth as: Date;
		define: #address as: Address dependent;
		define: #orders as: (OrderedCollection of: CustomerOrder dependent owner: #customer);
		yourself.
```

A couple of things worth highlighting here:
 - `define: #address as: Address dependent` - adding `dependent` to a definition means that object is dependent on the originating object for its existence. In this case the customer's address object is dependent on the owning customer - this means any changes to the address will be saved along with the customer, and the address will be deleted if the customer is deleted. 
 - `define: #orders as: (OrderedCollection of: CustomerOrder dependent owner: #customer)` - this is an example of an owned collection definition. An owned collection is one where the elements of the collection contain a reference to the owner of the collection. In this case instances of Order refer to their owning customer via their customer instance variable. 

# Creating the Database
With ReStore definitions created for all classes we can now connect to the database and create the database structure:

```smalltalk
ReStore
	connection: (SSWSQLite3Connection on: (Smalltalk imageDirectory / 'test.db') fullName);
	connect;
	addClasses: {Customer. Address. CustomerOrder. CustomerOrderItem. Product};
	synchronizeAllClasses.
```

 - for simplicity we're using [SQLite](https://www.sqlite.org/); please ensure the SQLite3 library/DLL is available to your image. If you'd rather use PostgreSQL you'll need to specify a connection similar to this:   
 `(SSWP3Connection new url: 'psql://user:pwd@192.168.1.234:5432/database')`   
 or for MySQL you'll need a connection similar to this:    
 `(SSWMySQLConnection new connectionSpec: (MySQLDriverSpec new db: 'database'; host: '192.168.1.234'; port: 3306; user: 'user'; password: 'pwd'; yourself); yourself)`
- `synchronizeAllClasses` prompts ReStore to create the necessary database tables for the classes `Customer`, `Address`, `Order` and `Product`. If you subsequently modify these classes (and their ReStore definitions) you can run `synchronizeAllClasses` again to prompt ReStore to automatically update the table definitions (add or remove columns from the tables) to match the updated class definitions.

# Storing Objects
With the database setup we can now create and persist objects using the `store` message:

```smalltalk
Customer new
	firstName: 'John';
	surname: 'Smith';
	address: (Address new country: 'UK'; yourself);
	store.

Customer new
	firstName: 'Jen';
	surname: 'Smith';
	address: (Address new country: 'France'; yourself);
	store.
````

# Reading Objects
Now we have some objects in the database we need a way to find and read them. ReStore does this via the message `storedInstances` which gives a virtual collection of instances of a particular class stored in the database. The virtual collection can then be queried using the familiar Smalltalk collection enumeration messages `select:`, `detect:` etc.

```smalltalk
"All Smiths"
Customer storedInstances select: [ :each | each surname = 'Smith'].

"John Smith"
Customer storedInstances select: [ :each | (each firstName = 'John') & (each surname = 'Smith')].
"alternatively:"
Customer storedInstances select: [ :each | each fullName = 'John Smith'].

"Customers in France"
Customer storedInstances select: [ :each | each address country = 'France'].
```

ReStore analyses the block argument to `select:`, `detect:` etc., translating this to SQL which is used to query the database. In this way required objects can be efficiently located without having to read all objects into the image. If all objects are required this can be done by converting the `storedInstances` virtual collection to a real collection:

```smalltalk
Customer storedInstances asOrderedCollection
```

# Updating Objects
Persisting changes to objects is also done using the `store` message:

```smalltalk
"Updating a Customer"
johnSmith := Customer storedInstances detect: [ :each | each fullName = 'John Smith'].
johnSmith dateOfBirth: (Date newDay: 1 monthIndex: 2 year: 1983).
johnSmith address postcode: 'W1 1AA'.
johnSmith store.

"Check it:"
Customer storedInstances detect: [ :each | each address postcode = 'W1 1AA'].

"Creating an Order - first we need a product"
widget := Product new name: 'Widget'; price: 2.5s2; store; yourself.

johnSmith 
    addOrder: 
        (CustomerOrder new 
            orderDate: Date today;
            addItem: 
	    	(CustomerOrderItem new
			product: widget;
			quantity: 4;
			yourself);
            yourself);
    store.

"Check it:"
Customer storedInstances detect: [ :each | each orders anySatisfy: [ :order | order totalPrice = 10]].
```

# Next Steps
This is just a sample of what ReStore can do, with an empahsis on simplicity. ReStore also supports more sophisticated usage patterns including:
 - transactions with automatic change-tracking
 - multi-user update clash detection and resolution
 - persistent class hierarchies
 - multiple, independent ReStore instances, including per-process and per-session support
 - query-by-example (template queries)
 - customisable Smalltalk-to-SQL conversion
 
A complete user manual can be found in the [Documentation folder](Documentation) (or [view online here](https://drive.google.com/file/d/1nDzLyokK8ZUAJuCh4J_H8MT_f3ZogMxy/view?usp=sharing)). Please also see the included SUnits for more examples. 
