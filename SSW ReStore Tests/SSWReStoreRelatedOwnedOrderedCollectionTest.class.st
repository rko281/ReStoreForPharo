"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreRelatedOwnedOrderedCollectionTest,
	#superclass : #SSWReStoreGenericRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedOwnedOrderedCollectionTest class >> allTestSelectors [

	^super allTestSelectors 
		removeAll: self multipleOccurrenceTestSelectors;
		yourself
]

{ #category : #helpers }
SSWReStoreRelatedOwnedOrderedCollectionTest >> _testCollectionElementTransferOf: element from: collection1 ownedBy: owner1 to: collection2 ownedBy: owner2 [

	collection1 remove: element.
	collection2 add: element.

	"To help with any debugging"
	owner1 name: 'one'.
	owner2 name: 'two'.

	{owner1. owner2} storeAll.

	element refresh.
	self assert: element owner equals: owner2
]

{ #category : #accessing }
SSWReStoreRelatedOwnedOrderedCollectionTest >> componentDefinition [

	^OrderedCollection of: GenericOwnedTest related owner: #owner
]

{ #category : #public }
SSWReStoreRelatedOwnedOrderedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection at: aCollection size) -> (aCollection at: aCollection size put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreRelatedOwnedOrderedCollectionTest >> templateCollection [

	^OrderedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]

{ #category : #tests }
SSWReStoreRelatedOwnedOrderedCollectionTest >> testCollectionElementRemovalWithNilBackpointer [

	"Verify that an element removed from the collection is stored correctly even if the backpointer is manually nil'd out"

	| size element id cls |

	size := collection size.
	element := collection anyOne. 
	id := element _id.
	cls := element class.

	collection remove: element.
	element owner: nil.
	testObject store.

	reStore simulateReconnect.
	self fetchTestObjects.

	self assert: collection size equals: size - 1.
	((cls storedInstancesIn: reStore) detect: [ :each | each _id = id] ifNone: [nil]) ifNotNil: [ :elem | self deny: (collection includes: elem)].

	self _testComponentExistenceOnDependency: element
]

{ #category : #tests }
SSWReStoreRelatedOwnedOrderedCollectionTest >> testCollectionElementTransfer [

	"Verify that an element transferred between owner collections retains its new owner link after commit/refresh.
	Previously, depending on the ordering within the transaction (variable, so happened around 50% of the time) the removal could nil out the link after the new link has been established.
	This would leave the element owner-less after commit"

	| collection1 element template2 collection2 |

	collection1 := collection.
	element := collection1 anyOne. 

	template2 := self templateTestObject storeIn: reStore; yourself.
	collection2 := template2 component.

	"Since the error only happened around 50% of the time we run the transfer and test multiple times"
	4 timesRepeat: 
		[self 
			_testCollectionElementTransferOf: element from: collection1 ownedBy: testObject to: collection2 ownedBy: template2;
			_testCollectionElementTransferOf: element from: collection2 ownedBy: template2 to: collection1 ownedBy: testObject]
]
