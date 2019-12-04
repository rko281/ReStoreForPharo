"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreCollectionSubQueryTest,
	#superclass : #SSWReStoreProductOrdersTest,
	#instVars : [
		'customers',
		'goldPlatedWobulator'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreCollectionSubQueryTest class >> isAbstract [

	^self == SSWReStoreCollectionSubQueryTest
]

{ #category : #public }
SSWReStoreCollectionSubQueryTest class >> myTestSelectors [

	^SSWReStoreCollectionSubQueryTest testSelectors
]

{ #category : #running }
SSWReStoreCollectionSubQueryTest >> setUp [

	| orders |

	super setUp.

	reStore evaluateAsTransaction: 
		[SimpleProduct new
			description: 'gold-plated wobulator';
			supplierPrice: 1000;
			retailPrice: 2000;
			storeIn: reStore].

	goldPlatedWobulator := (reStore instancesOf: SimpleProduct) detect: [ :each | each retailPrice = 2000].

	orders := OrderedCollection new.

	1 to: 10 do: [ :index | orders add: (customer1 orders add: (SimpleProductOrder new product: widget; quantity: (index * 10); customer: customer1; yourself))].
	1 to: 5 do: [ :index | orders add: (customer2 orders add: (SimpleProductOrder new product: widget; quantity: (index * 10); customer: customer2; yourself))].
	5 to: 10 do: [ :index | orders add: (customer3 orders add: (SimpleProductOrder new product: widget; quantity: (index * 10); customer: customer3; yourself))].

	1 to: 5 do: [ :index | orders add: (customer1 orders add: (SimpleProductOrder new product: gadget; quantity: (index * 10); customer: customer1; yourself))].
	1 to: 15 do: [ :index | orders add: (customer2 orders add: (SimpleProductOrder new product: gadget; quantity: (index * 10); customer: customer2; yourself))].
	
	1 to: 10 do: [ :index | orders add: (customer1 orders add: (SimpleProductOrder new product: wobulator; quantity: (index * 100); customer: customer1; yourself))].

	reStore commitAll: 
		((OrderedCollection withAll: orders)
			add: customer1 withRelatedComponents;
			add: customer2 withRelatedComponents;
			add: customer3 withRelatedComponents;
			yourself).

	reStore refreshAllObjects.

	customers := reStore instancesOf: SimplePerson
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testAnySatisfyDeep [

	| matches |

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product supplierPrice = 1]].
	self assert: (matches size = 3).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self assert: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product retailPrice = 6]].
	self assert: (matches size = 2).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self deny: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product supplierPrice = 100]].
	self assert: (matches size = 1).
	self assert: (matches first == customer1).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product retailPrice = 2000]].
	self assert: (matches isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testAnySatisfyPersistent [

	| matches |

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product = widget]].
	self assert: (matches size = 3).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self assert: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product = gadget]].
	self assert: (matches size = 2).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self deny: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product = wobulator]].
	self assert: (matches size = 1).
	self assert: (matches first == customer1).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order product = goldPlatedWobulator]].
	self assert: (matches isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testAnySatisfySimple [

	| matches |

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order quantity >= 100]].
	self assert: (matches size = 3).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self assert: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order quantity >= 150]].
	self assert: (matches size = 2).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self deny: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order quantity >= 200]].
	self assert: (matches size = 1).
	self assert: (matches first == customer1).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order quantity >= 1000]].
	self assert: (matches size = 1).
	self assert: (matches first == customer1).

	matches := customers select: [ :each | each orders anySatisfy: [ :order | order quantity > 1000]].
	self assert: (matches isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testCollectFirst [

	| results |

	results := Dictionary withAll: (customers collect: [ :each | each -> each orders first]).

	"Note we don't get an error for an empty collection"
	self assert: results size = 4.
	self assert: ((results at: customer1) quantity = 10).
	self assert: ((results at: customer2) quantity = 10).
	self assert: ((results at: customer3) quantity = 50).
	self assert: ((results at: customer4) isNil)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testCollectLast [

	| results |

	results := Dictionary withAll: (customers collect: [ :each | each -> each orders last]).

	"Note we don't get an error for an empty collection"
	self assert: results size = 4.
	self assert: ((results at: customer1) quantity = 1000).
	self assert: ((results at: customer2) quantity = 150).
	self assert: ((results at: customer3) quantity = 100).
	self assert: ((results at: customer4) isNil)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testCollectionSize [

	| matches |

	matches := customers select: [ :each | each orders size >= 6].
	self assert: (matches size = 3).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self assert: (matches includes: customer3).

	matches := customers select: [ :each | each orders size > 6].
	self assert: (matches size = 2).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).

	matches := customers select: [ :each | each orders size = 25].
	self assert: (matches size = 1).
	self assert: (matches first = customer1).

	matches := customers select: [ :each | each orders size <= 6].
	self assert: (matches size = 1).
	self assert: (matches first = customer3).

	matches := customers select: [ :each | each orders size = 0].
	self assert: (matches size = 1).
	self assert: (matches first = customer4).
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testIncludes [

	{customer1. customer2. customer3} do:
		[ :customer || testOrder matches otherCustomers |
		testOrder := customer orders first.

		matches := customers select: [ :each | each orders includes: testOrder].
		self assert: (matches size = 1).
		self assert: (matches first == customer).

		otherCustomers := customers asOrderedCollection reject: [ :each | each == customer].

		matches := customers select: [ :each | (each orders includes: testOrder) not].
		self assert: (matches size = 3).
		self deny: (matches includes: customer).
		self assert: (otherCustomers allSatisfy: [ :otherCustomer | matches includes: otherCustomer])]
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testIsEmpty [

	| matches |

	matches := customers select: [ :each | each orders isEmpty].
	self assert: (matches size = 1).
	self assert: (matches first == customer4)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testIsNotEmpty [

	| matches |

	matches := customers select: [ :each | each orders isEmpty not].
	self assert: (matches size = 3).
	self deny: (matches anySatisfy: [ :each | each == customer4])
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testSelectSimpleCollectFirst [

	| results |

	results := Dictionary withAll: (customers collect: [ :each | each -> ((each orders select: [ :order | order quantity >= 100]) first)]).

	self assert: results size = 3.
	self assert: ((results at: customer1) quantity = 100).
	self assert: ((results at: customer2) quantity = 100).
	self assert: ((results at: customer3) quantity = 100)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testSelectSimpleCollectSize [

	| results |

	results := Dictionary withAll: (customers collect: [ :each | each -> ((each orders select: [ :order | order quantity >= 100]) size)]).

	self assert: results size = 3.
	self assert: ((results at: customer1) = 11).
	self assert: ((results at: customer2) = 6).
	self assert: ((results at: customer3) = 1)
]

{ #category : #'unit tests' }
SSWReStoreCollectionSubQueryTest >> testSelectSimpleSizeComparison [

	| matches |

	matches := customers select: [ :each | (each orders select: [ :order | order quantity >= 100]) size >=1].
	self assert: (matches size = 3).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self assert: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | (each orders select: [ :order | order quantity >= 100]) size >= 5].
	self assert: (matches size = 2).
	self assert: (matches includes: customer1).
	self assert: (matches includes: customer2).
	self deny: (matches includes: customer3).
	self deny: (matches includes: customer4).

	matches := customers select: [ :each | (each orders select: [ :order | order quantity >= 100]) size >= 10].
	self assert: (matches size = 1).
	self assert: (matches first == customer1).

	matches := customers select: [ :each | (each orders select: [ :order | order quantity >= 1000]) size >= 10].
	self assert: (matches isEmpty)
]
