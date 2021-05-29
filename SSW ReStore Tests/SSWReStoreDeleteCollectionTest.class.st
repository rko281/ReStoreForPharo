Class {
	#name : #SSWReStoreDeleteCollectionTest,
	#superclass : #SSWReStoreReadWithComponentsTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDeleteCollectionTest class >> isAbstract [

	^self = SSWReStoreDeleteCollectionTest
]

{ #category : #'unit tests' }
SSWReStoreDeleteCollectionTest >> _testDeleteAll [

	customers := customers asOrderedCollection.

	Transcript cr; print: (Time millisecondsToRun: [reStore evaluateAsTransaction: [customers unstoreAll]]); flush
]

{ #category : #constants }
SSWReStoreDeleteCollectionTest >> deleteCustomer1QueriesCount [

	"How many queries to delete customer1?"
	^1 + self deleteQueriesCount "delete customer + delete collection"
]

{ #category : #constants }
SSWReStoreDeleteCollectionTest >> deleteCustomer2QueriesCount [

	"How many queries to delete customer2?"
	^1 + self deleteQueriesCount "delete customer + delete collection"
]

{ #category : #constants }
SSWReStoreDeleteCollectionTest >> deleteProxiedCollectionQueryCount [

	^3 + self deleteCustomer2QueriesCount "read customer + read collection + delete customer + delete query(s)"
]

{ #category : #constants }
SSWReStoreDeleteCollectionTest >> deleteQueriesCount [

	"How many queries to delete a collection?"
	^self subclassResponsibility
]

{ #category : #constants }
SSWReStoreDeleteCollectionTest >> deproxyQueryCount [

	^2 "read customer + read collection"
]

{ #category : #constants }
SSWReStoreDeleteCollectionTest >> otherCustomersSize [

	"Not used here"
	^0
]

{ #category : #'unit tests' }
SSWReStoreDeleteCollectionTest >> testDeleteProxiedCollectionQueryCount [

	self assert: customer2 isDBProxy.

	self resetQueryCount.
	self assert: customer2 unstore.
	self assert: self queryCount equals: self deproxyQueryCount + self deleteCustomer2QueriesCount
]

{ #category : #'unit tests' }
SSWReStoreDeleteCollectionTest >> testDeleteUnproxiedCollectionQueryCount [

	customer1 orders size.
	self deny: customer1 isDBProxy.
	self deny: customer1 orders isDBProxy.

	self resetQueryCount.
	self assert: customer1 unstore.
	self assert: self queryCount equals: self deleteCustomer1QueriesCount
]
