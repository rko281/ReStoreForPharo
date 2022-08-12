"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreProductOrdersTest,
	#superclass : #SSWReStoreQueryTest,
	#instVars : [
		'widget',
		'gadget',
		'wobulator',
		'customer1',
		'customer2',
		'customer3',
		'customer4'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreProductOrdersTest class >> isAbstract [

	^self == SSWReStoreProductOrdersTest
]

{ #category : #public }
SSWReStoreProductOrdersTest class >> shouldInheritSelectors [

	^false
]

{ #category : #running }
SSWReStoreProductOrdersTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore addClass: SimpleProductOrder.

	(aReStore tableForClass: SimplePerson) define: #orders as: self ordersCollectionDefinition
]

{ #category : #running }
SSWReStoreProductOrdersTest >> createTestData [

	| products customers |

	super createTestData.

	self createProducts.

	products := (SimpleProduct storedInstancesIn: reStore) asOrderedCollection.
	widget := products detect: [ :each | each description = 'widget'].
	gadget := products detect: [ :each | each description = 'gadget'].
	wobulator := products detect: [ :each | each description = 'wobulator'].

	customers := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	customers size = 4 ifFalse: [self error: 'test data incorrect'].
	customer1 := customers first.
	customer2 := customers second.
	customer3 := customers third.
	customer4 := customers last
]

{ #category : #constants }
SSWReStoreProductOrdersTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder related owner: #customer)
]
