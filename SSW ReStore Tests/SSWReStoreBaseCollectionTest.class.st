Class {
	#name : #SSWReStoreBaseCollectionTest,
	#superclass : #SSWReStoreGenericTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreBaseCollectionTest >> _testCommit: aTestObject [

	self assert: aTestObject component class equals: self collectionClass.
	self assert: aTestObject component size equals: 6.
	self assert: (aTestObject component asSortedCollection: [ :a :b | a ifNil: [true] ifNotNil: [b ifNil: [false] ifNotNil: [a < b]]]) asArray equals: #(nil nil 'Alan' 'Barry' 'Colin' 'Daisy').
	#('Alan' 'Barry' 'Colin' nil 'Daisy' nil) keysAndValuesDo: [ :key :value | self assert: (aTestObject component at: key) equals: value]
]

{ #category : #helpers }
SSWReStoreBaseCollectionTest >> _testVerifySetup: aTestObject [

	self assert: aTestObject component class equals: self collectionClass.
	self assert: aTestObject component size equals: 4.
	self assert: (aTestObject component asSortedCollection: [ :a :b | a ifNil: [true] ifNotNil: [b ifNil: [false] ifNotNil: [a < b]]]) asArray equals: #(nil 'Alan' 'Barry' 'Colin').
	#('Alan' 'Barry' 'Colin' nil) keysAndValuesDo: [ :key :value | self assert: (aTestObject component at: key) equals: value]
]

{ #category : #helpers }
SSWReStoreBaseCollectionTest >> addToCollection: anObject [

	"Return the key"

	^self addToCollection: anObject at: testObject component size + 1
]

{ #category : #helpers }
SSWReStoreBaseCollectionTest >> addToCollection: anObject at: anInteger [

	testObject component add: anObject beforeIndex: anInteger.

	^anInteger
]

{ #category : #accessing }
SSWReStoreBaseCollectionTest >> collectionClass [

	^OrderedCollection
]

{ #category : #accessing }
SSWReStoreBaseCollectionTest >> componentDefinition [

	^OrderedCollection of: (String maxSize: 64)
]

{ #category : #helpers }
SSWReStoreBaseCollectionTest >> removeFromCollection: anObject [

	"Return the key of the removed object"

	^self removeFromCollection: anObject at: (testObject component indexOf: anObject)
]

{ #category : #helpers }
SSWReStoreBaseCollectionTest >> removeFromCollection: anObject at: anInteger [

	"Return the key/index of the removed object"

	"key has no meaning here"
	testObject component remove: anObject.
	^anInteger
]

{ #category : #accessing }
SSWReStoreBaseCollectionTest >> templateTestObject [

	| template |

	testObject := GenericTest new.
	testObject component: self collectionClass new.

	"nil previously caused issues"
	#('Alan' 'Barry' 'Colin' nil) do: [ :name | self addToCollection: name].

	template := testObject.
	testObject := nil.
	^template
	
]

{ #category : #'unit tests' }
SSWReStoreBaseCollectionTest >> testCommit [

	self 
		addToCollection: 'Daisy';
		addToCollection: nil.

	testObject store.

	self fetchTestObjects.

	self _testCommit: testObject
]

{ #category : #'unit tests' }
SSWReStoreBaseCollectionTest >> testHasChanged [

	| key |

	self deny: testObject hasChanged.

	key := self removeFromCollection: 'Alan'.
	self assert: testObject hasChanged. 
	self addToCollection: 'Alan' at: key.
	self deny: testObject hasChanged.

	key := self removeFromCollection: nil.
	self assert: testObject hasChanged. 
	self addToCollection: nil at: key.
	self deny: testObject hasChanged.

	self addToCollection: 'Daisy'.
	self assert: testObject hasChanged. 
	self removeFromCollection: 'Daisy'.
	self deny: testObject hasChanged.

	key := self addToCollection: nil.
	self assert: testObject hasChanged. 
	self removeFromCollection: nil at: key.
	self deny: testObject hasChanged.


]

{ #category : #'unit tests' }
SSWReStoreBaseCollectionTest >> testRefresh [

	self _testVerifySetup: testObject2.

	self 
		addToCollection: 'Daisy';
		addToCollection: nil.

	testObject store.

	"No change yet"
	self _testVerifySetup: testObject2.

	"Refresh and re-test"
	testObject2 refresh.
	self _testCommit: testObject2
]

{ #category : #'unit tests' }
SSWReStoreBaseCollectionTest >> testRollback [

	self 
		addToCollection: 'Daisy';
		addToCollection: nil.

	testObject rollback.

	self testVerifySetup
]

{ #category : #'unit tests' }
SSWReStoreBaseCollectionTest >> testVerifySetup [

	self _testVerifySetup: testObject
]
