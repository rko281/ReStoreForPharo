Class {
	#name : #SSWReStoreDeleteRelatedCollectionTest,
	#superclass : #SSWReStoreDeleteCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDeleteRelatedCollectionTest class >> isAbstract [

	^self = SSWReStoreDeleteRelatedCollectionTest
]

{ #category : #public }
SSWReStoreDeleteRelatedCollectionTest class >> myTestSelectors [

	^SSWReStoreDeleteCollectionTest testSelectors, SSWReStoreDeleteRelatedCollectionTest testSelectors
]

{ #category : #'unit tests' }
SSWReStoreDeleteRelatedCollectionTest >> testDeleteProxiedCollection [

	| allOrders totalOrderCount id |

	allOrders := SimpleProductOrder storedInstancesIn: reStore.
	totalOrderCount := allOrders size.

	id := customer2 _id.
	self assert: customer2 isDBProxy.
	self assert: customer2 unstore.

	self deny: ((SimplePerson storedInstancesIn: reStore) anySatisfy: [ :each | each _id = id]).
	self assert: allOrders size equals: totalOrderCount
]

{ #category : #'unit tests' }
SSWReStoreDeleteRelatedCollectionTest >> testDeleteUnproxiedCollection [

	| allOrders totalOrderCount id |

	allOrders := SimpleProductOrder storedInstancesIn: reStore.
	totalOrderCount := allOrders size.

	id := customer1 _id.
	self deny: customer1 isDBProxy.
	self assert: customer1 unstore.

	self deny: ((SimplePerson storedInstancesIn: reStore) anySatisfy: [ :each | each _id = id]).
	self assert: allOrders size equals: totalOrderCount
]
