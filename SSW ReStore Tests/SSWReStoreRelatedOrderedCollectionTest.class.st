"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreRelatedOrderedCollectionTest',
	#superclass : 'SSWReStoreGenericRelatedCollectionTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'accessing' }
SSWReStoreRelatedOrderedCollectionTest >> componentDefinition [

	^OrderedCollection of: GenericOwnedTest related
]

{ #category : 'helpers' }
SSWReStoreRelatedOrderedCollectionTest >> duplicateInCollection: aCollection [

	^aCollection at: 1 put: aCollection last
]

{ #category : 'public' }
SSWReStoreRelatedOrderedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection at: aCollection size) -> (aCollection at: aCollection size put: self templateComponent)
]

{ #category : 'accessing' }
SSWReStoreRelatedOrderedCollectionTest >> templateCollection [

	^OrderedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]

{ #category : 'unit tests' }
SSWReStoreRelatedOrderedCollectionTest >> testCheckHasChangedComponentSwap [

	"Only relevant to non-owned"

	| first |

	first := collection first.
	collection 
		at: 1 put: collection last;
		at: collection size put: first.

	"Change of ordering does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : 'unit tests' }
SSWReStoreRelatedOrderedCollectionTest >> testCommitComponentSwap [

	"Only relevant to non-owned"

	| first last |

	first := collection first.
	last := collection last.
	collection 
		at: 1 put: last;
		at: collection size put: first.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (collection first name = first name).
	self assert: (collection last name = last name).

	first := collection first.
	last := collection last.
	collection 
		at: 1 put: last;
		at: collection size put: first.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (collection first name = last name).
	self assert: (collection last name = first name).

]

{ #category : 'unit tests' }
SSWReStoreRelatedOrderedCollectionTest >> testDuplicateEntries [

	"Ensure duplicate entries are handled correctly"

	self duplicateInCollection.

	"This should just involve an update of the value of the entry to which the duplicate has been assigned.
	Previously this would update the duplicated entry's key, add a new entry for the original and delete the original entry"
	self assert: (self countQueriesDuring: [testObject store]) equals: (1 "for the update" + (self componentDefinition isValueDependent ifTrue: [1] ifFalse: [0]) "1 for the deletion of the overwritten item (if dependent)")
]

{ #category : 'unit tests' }
SSWReStoreRelatedOrderedCollectionTest >> testRollbackComponentSwap [

	"Only relevant to non-owned"

	| first last |

	first := collection first.
	last := collection last.
	collection 
		at: 1 put: last;
		at: collection size put: first.

	reStore rollback: testObject.
	self assert: (collection last == first).
	self assert: (collection first == last).

	reStore rollback: testObject withRelatedComponents.
	self assert: (collection first == first).
	self assert: (collection last == last)
]
