Class {
	#name : 'SSWReStoreDeleteDependentCollectionTest',
	#superclass : 'SSWReStoreDeleteCollectionTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreDeleteDependentCollectionTest class >> isAbstract [

	^self = SSWReStoreDeleteDependentCollectionTest
]

{ #category : 'public' }
SSWReStoreDeleteDependentCollectionTest class >> myTestSelectors [

	^SSWReStoreDeleteCollectionTest testSelectors, SSWReStoreDeleteDependentCollectionTest testSelectors
]

{ #category : 'unit tests' }
SSWReStoreDeleteDependentCollectionTest >> testDeleteProxiedCollection [

	| allOrders totalOrderCount customer1OrderCount customer2OrderCount customer3OrderCount id |

	allOrders := SimpleProductOrder storedInstancesIn: reStore.
	totalOrderCount := allOrders size.
	customer1OrderCount := customer1 orders size.
	customer2OrderCount := (allOrders satisfying: [ :each | each customer = customer2]) size.
	customer3OrderCount := customer3 orders size.

	id := customer2 _id.
	self assert: customer2 isDBProxy.
	self assert: customer2 unstore.

	self deny: ((SimplePerson storedInstancesIn: reStore) anySatisfy: [ :each | each _id = id]).
	self assert: allOrders size equals: (totalOrderCount - customer2OrderCount).
	self assert: (allOrders satisfying: [ :each | each customer = customer1]) size equals: customer1OrderCount.
	self assert: (allOrders satisfying: [ :each | each customer = customer3]) size equals: customer3OrderCount
]

{ #category : 'unit tests' }
SSWReStoreDeleteDependentCollectionTest >> testDeleteUnproxiedCollection [

	| allOrders totalOrderCount customer1OrderCount customer2OrderCount customer3OrderCount id |

	allOrders := SimpleProductOrder storedInstancesIn: reStore.
	totalOrderCount := allOrders size.
	customer1OrderCount := customer1 orders size.
	customer2OrderCount := customer2 orders size.
	customer3OrderCount := customer3 orders size.

	id := customer1 _id.
	self deny: customer1 isDBProxy.
	self assert: customer1 unstore.

	self deny: ((SimplePerson storedInstancesIn: reStore) anySatisfy: [ :each | each _id = id]).
	self assert: allOrders size equals: (totalOrderCount - customer1OrderCount).
	self assert: (allOrders satisfying: [ :each | each customer = customer2]) size equals: customer2OrderCount.
	self assert: (allOrders satisfying: [ :each | each customer = customer3]) size equals: customer3OrderCount
]
