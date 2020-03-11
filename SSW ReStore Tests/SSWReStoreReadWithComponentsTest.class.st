"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreReadWithComponentsTest,
	#superclass : #SSWReStoreProductOrdersTest,
	#instVars : [
		'customers'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreReadWithComponentsTest class >> isAbstract [

	^self == SSWReStoreReadWithComponentsTest
]

{ #category : #public }
SSWReStoreReadWithComponentsTest class >> myTestSelectors [

	^SSWReStoreReadWithComponentsTest testSelectors
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> _testCollection [

	| time1 time2 |


	time1 :=Time millisecondsToRun: [10 timesRepeat: [
	reStore clearProxyCache.
	customers asOrderedCollection collect: [ :e | e -> e orders size]]].

	time2 :=Time millisecondsToRun: [| spec |
	spec := (reStore tableForClass: SimplePerson) collectionAccessing: #orders.
	10 timesRepeat: [| oc |
	reStore clearProxyCache.
	oc := customers asOrderedCollection.
	spec readAllFor: oc.
	oc collect: [ :e | e -> e orders size]]].

	(time1 -> time2) inspect
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> _testProxyCollectionTiming [

	| time1 time2 |

	time1 :=Time millisecondsToRun: [10 timesRepeat: [
	reStore clearProxyCache.
	customers asOrderedCollection collect: [ :e | e -> e orders size]]].

	time2 :=Time millisecondsToRun: [10 timesRepeat: [
	reStore clearProxyCache.
	(customers include: #orders) asOrderedCollection collect: [ :e | e -> e orders size]]].

	(time1 -> time2) inspect
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> _testProxySingleObjectTiming [

	| time1 time2 |

	time1 :=Time millisecondsToRun: [10 timesRepeat: [
	reStore clearProxyCache.
	customers asOrderedCollection collect: [ :e | e -> e test name]]].

	time2 :=Time millisecondsToRun: [10 timesRepeat: [
	reStore clearProxyCache.
	(customers include: #test) asOrderedCollection collect: [ :e | e -> e test name]]].

	(time1 -> time2) inspect
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> _testTiming [

	| t1 t2 |

	t1 := Time millisecondsToRun: [1000 timesRepeat: [(reStore executeSQL: 'select * from simple_person') close]].
	t2 := Time millisecondsToRun: [1000 timesRepeat: [(reStore connection exec: 'select * from simple_person') close]].
	
	(t1 -> t2) inspect
]

{ #category : #running }
SSWReStoreReadWithComponentsTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore addClass: Test
]

{ #category : #running }
SSWReStoreReadWithComponentsTest >> createTestData [

	| orders otherCustomers |

	super createTestData.

	orders := OrderedCollection new.

	1 to: 10 do: [ :index | orders add: (customer1 orders add: (SimpleProductOrder new product: widget; quantity: (index * 10); customer: customer1; yourself))].
	1 to: 5 do: [ :index | orders add: (customer2 orders add: (SimpleProductOrder new product: widget; quantity: (index * 10); customer: customer2; yourself))].
	1 to: 1 do: [ :index | orders add: (customer3 orders add: (SimpleProductOrder new product: widget; quantity: (index * 10); customer: customer3; yourself))].

	1 to: 1 do: [ :index | orders add: (customer1 orders add: (SimpleProductOrder new product: gadget; quantity: (index * 10); customer: customer1; yourself))].
	1 to: 5 do: [ :index | orders add: (customer2 orders add: (SimpleProductOrder new product: gadget; quantity: (index * 10); customer: customer2; yourself))].
	1 to: 10 do: [ :index | orders add: (customer3 orders add: (SimpleProductOrder new product: gadget; quantity: (index * 10); customer: customer3; yourself))].
	
	otherCustomers := (1 to: self otherCustomersSize) collect: 
		[ :each || customer |
		customer := SimplePerson new.
		customer surname: each displayString; test: (Test new name: ('*<1p>*' expandMacrosWith: each)).
		(each \\ 10) timesRepeat: [customer orders add: (SimpleProductOrder new product: wobulator; quantity: each; customer: customer; yourself)].
		customer].
	
	((OrderedCollection withAll: orders)
		add: customer1;
		add: customer2;
		add: customer3;
		addAll: otherCustomers;
		yourself) storeAllIn: reStore.

	customers := SimplePerson storedInstancesIn: reStore.

	reStore refreshAllObjects.

	"Ensure we have a mix of proxied and unproxied objects"
	customer1 surname.
	customer4 surname.

	self deny: customer1 isDBProxy.
	self assert: customer2 isDBProxy.
	self assert: customer3 isDBProxy.
	self deny: customer4 isDBProxy
]

{ #category : #running }
SSWReStoreReadWithComponentsTest >> otherCustomersSize [

	^105
]

{ #category : #running }
SSWReStoreReadWithComponentsTest >> setUp [

	super setUp.
	self countQueries
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testCollection [

	| allCustomers |

	allCustomers := customers asOrderedCollection.

	"Fetching allCustomers' orders should take sufficient batched readAll queries for the current batch size to cover all customers"
	self resetQueryCount.
	allCustomers fetch: #orders.
	self assert: (self queryCount = ((allCustomers size / reStore readAllBatchSize) ceiling)).

	"Recover all products and reset the count"
	(SimpleProduct storedInstancesIn: reStore) asOrderedCollection.
	self resetQueryCount.

	self assert: (allCustomers size = (self otherCustomersSize + 4)).

	self assert: customer1 orders size = 11.
	self assert: customer2 orders size = 10.
	self assert: customer3 orders size = 11.

	self assert: (customer1 orders select: [ :each | each product = widget]) size = 10.
	self assert: (customer2 orders select: [ :each | each product = widget]) size = 5.
	self assert: (customer3 orders select: [ :each | each product = widget]) size = 1.

	self assert: (customer1 orders select: [ :each | each product = gadget]) size = 1.
	self assert: (customer2 orders select: [ :each | each product = gadget]) size = 5.
	self assert: (customer3 orders select: [ :each | each product = gadget]) size = 10.

	allCustomers do: 
		[ :each || num |
		((Array with: customer1 with: customer2 with: customer3 with: customer4) includes: each) ifFalse: 
			[num := Integer readFrom: each surname readStream.
			self assert: (each orders size = (num \\ 10)).
			self assert: (each orders allSatisfy: [ :order | order product = wobulator]).
			self assert: (each orders allSatisfy: [ :order | order quantity = num])]].

	"No further queries should have occurred"
	self assert: (self queryCount = 0)
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testEmptyCollection [

	"Previously caused an error"

	| noCustomers |

	noCustomers := customers select: [ :each | each firstName = 'Shadrack'].

	self shouldnt: [noCustomers fetch: #orders] raise: Error
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testProxyCollection [

	| allCustomers |

	"Reading all customers with their orders should only take 1 query for the customers themselves, plus sufficient batched readAll queries for the current batch size to cover all customers"
	self resetQueryCount.
	allCustomers := (customers include: #orders) asOrderedCollection.
	self assert: (self queryCount = (1 + (allCustomers size / reStore readAllBatchSize) ceiling)).

	"Recover all products and reset the count"
	(SimpleProduct storedInstancesIn: reStore) asOrderedCollection.
	self resetQueryCount.

	self assert: (allCustomers size = (self otherCustomersSize + 4)).

	self assert: customer1 orders size = 11.
	self assert: customer2 orders size = 10.
	self assert: customer3 orders size = 11.

	self assert: (customer1 orders select: [ :each | each product = widget]) size = 10.
	self assert: (customer2 orders select: [ :each | each product = widget]) size = 5.
	self assert: (customer3 orders select: [ :each | each product = widget]) size = 1.

	self assert: (customer1 orders select: [ :each | each product = gadget]) size = 1.
	self assert: (customer2 orders select: [ :each | each product = gadget]) size = 5.
	self assert: (customer3 orders select: [ :each | each product = gadget]) size = 10.

	allCustomers do: 
		[ :each || num |
		((Array with: customer1 with: customer2 with: customer3 with: customer4) includes: each) ifFalse: 
			[num := Integer readFrom: each surname readStream.
			self assert: (each orders size = (num \\ 10)).
			self assert: (each orders allSatisfy: [ :order | order product = wobulator]).
			self assert: (each orders allSatisfy: [ :order | order quantity = num])]].

	"No further queries should have occurred"
	self assert: (self queryCount = 0)
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testProxyCollectionMultipleRead [

	"Test for a previously-erroring case where a second readAll query overwrote the results from the first"

	| allCustomers |

	"Read and touch the orders"
	allCustomers := (customers include: #orders) asOrderedCollection.
	allCustomers do: [ :each | each orders size].

	"Reading again should only take one query for the collection itself"
	self resetQueryCount.
	allCustomers := (customers include: #orders) asOrderedCollection.
	self assert: (self queryCount = 1).

	"Recover all products and reset the count"
	(SimpleProduct storedInstancesIn: reStore) asOrderedCollection.
	self resetQueryCount.

	self assert: (allCustomers size = (self otherCustomersSize + 4)).

	self assert: customer1 orders size = 11.
	self assert: customer2 orders size = 10.
	self assert: customer3 orders size = 11.

	self assert: (customer1 orders select: [ :each | each product = widget]) size = 10.
	self assert: (customer2 orders select: [ :each | each product = widget]) size = 5.
	self assert: (customer3 orders select: [ :each | each product = widget]) size = 1.

	self assert: (customer1 orders select: [ :each | each product = gadget]) size = 1.
	self assert: (customer2 orders select: [ :each | each product = gadget]) size = 5.
	self assert: (customer3 orders select: [ :each | each product = gadget]) size = 10.

	allCustomers do: 
		[ :each || num |
		((Array with: customer1 with: customer2 with: customer3 with: customer4) includes: each) ifFalse: 
			[num := Integer readFrom: each surname readStream.
			self assert: (each orders size = (num \\ 10)).
			self assert: (each orders allSatisfy: [ :order | order product = wobulator]).
			self assert: (each orders allSatisfy: [ :order | order quantity = num])]].

	"No further queries should have occurred"
	self assert: (self queryCount = 0)
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testProxySingleObject [

	| allCustomers |

	"Reading all customers with their associated test objects should only take 1 query for the customers themselves, plus sufficient batched readAll queries for the current batch size to cover all customers"
	self resetQueryCount.
	allCustomers := (customers include: #test) asOrderedCollection.
	self assert: (self queryCount = (1 + ((allCustomers size - 4 "customers1-4 do not have a test inst var") / reStore readAllBatchSize) ceiling)).
	self resetQueryCount.

	self assert: (allCustomers size = (self otherCustomersSize + 4)).

	allCustomers do: 
		[ :each |
		((Array with: customer1 with: customer2 with: customer3 with: customer4) includes: each)
			ifTrue: [self assert: each test isNil]
			ifFalse: [self assert: (each test name = ('*', each surname, '*'))]].

	self assert: self queryCount = 0
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testProxySingleObjectMultipleRead [

	"Test for a previously-erroring case where a second readAll query overwrote the results from the first"

	| allCustomers |

	allCustomers := (customers include: #test) asOrderedCollection.
	allCustomers do: [ :each | each test _touch].

	"Reading again should only take one query for the collection since all tests are already recovered and touched"
	self resetQueryCount.
	allCustomers := (customers include: #test) asOrderedCollection.
	self assert: (self queryCount = 1).

	self assert: (allCustomers size = (self otherCustomersSize + 4)).

	self resetQueryCount.

	allCustomers do: 
		[ :each |
		((Array with: customer1 with: customer2 with: customer3 with: customer4) includes: each)
			ifTrue: [self assert: each test isNil]
			ifFalse: [self assert: (each test name = ('*', each surname, '*'))]].

	self assert: (self queryCount = 0)
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testRefreshCollection [

	| allCustomers testOrder originalQuantity |

	allCustomers := customers asOrderedCollection.
	
	testOrder := allCustomers first orders first.
	originalQuantity := testOrder quantity.

	"Update directly in database"
	reStore executeSQLAsTxn: {('update <1s> set quantity = quantity * 10 where id_ = <2p>' expandMacrosWith: (reStore tableForClass: testOrder class) name with: testOrder _id)}.

	"fetch: will miss the update since testOrder already exists in the image and has been viewed/touched"
	allCustomers fetch: #orders.
	self assert: testOrder quantity equals: originalQuantity.

	"Following a soft rollback however we should pick it up"
	reStore softRollback.
	allCustomers fetch: #orders.
	self assert: testOrder quantity equals: (originalQuantity * 10)
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testRefreshProxyCollection [

	| allCustomers testCustomer originalName newName testOrder originalQuantity |

	allCustomers := customers asOrderedCollection.
	
	testCustomer := allCustomers first.
	originalName := testCustomer surname.
	newName := originalName, '_CHANGED'.
	testOrder := (allCustomers detect: [ :each | each ~~ testCustomer and: [each orders isEmpty not]]) orders first.
	originalQuantity := testOrder quantity.

	"Update directly in database"
	reStore executeSQLAsTxn: 
		{('update <1s> set surname = <2p> where id_ = <3p>' expandMacrosWith: (reStore tableForClass: testCustomer class) name with: newName with: testCustomer _id).
		('update <1s> set quantity = quantity * 10 where id_ = <2p>' expandMacrosWith: (reStore tableForClass: testOrder class) name with: testOrder _id)}.

	"asOrderedCollection will miss the updates since testCustomer and testOrder already exist in the image and have been viewed/touched"
	customers asOrderedCollection.
	self assert: testCustomer surname = originalName.
	self assert: testOrder quantity = originalQuantity.

	"If #refreshed we should pick up the change to testCustomer - but not testOrder since we are not fetching this component"
	customers refreshed asOrderedCollection.
	self assert: testCustomer surname = newName.
	self assert: testOrder quantity = originalQuantity.

	"asOrderedCollection with the #orders component will now also refresh testOrder"
	(customers include: #orders) asOrderedCollection.
	self assert: testCustomer surname = newName.
	self assert: testOrder quantity = (originalQuantity * 10)
]

{ #category : #'unit tests' }
SSWReStoreReadWithComponentsTest >> testRefreshSingleObject [

	| allCustomers test originalName newName |

	allCustomers := customers asOrderedCollection.
	
	test := allCustomers last test.
	originalName := test name.
	newName := Time now displayString.

	"Update directly in database"
	reStore executeSQLAsTxn: {('update <1s> set name = <3p> where id_ = <2p>' expandMacrosWith: (reStore tableForClass: test class) name with: test _id with: newName)}.

	"fetchComponents: will miss the update since testOrder already exists in the image and has been viewed/touched"
	allCustomers fetch: #test.
	self assert: test name = originalName.

	"Following a soft rollback however we should pick it up"
	reStore softRollback.
	allCustomers fetch: #test.
	self assert: test name = newName
]
