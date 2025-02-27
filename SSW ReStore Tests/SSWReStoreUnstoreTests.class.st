Class {
	#name : 'SSWReStoreUnstoreTests',
	#superclass : 'SSWReStoreObjectAPITests',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreUnstoreTests class >> allTestSelectors [

	^self testSelectors
]

{ #category : 'running' }
SSWReStoreUnstoreTests >> _testCreateObjectWithCollection [

	| obj |

	obj := self _testCreateObject.

	1 to: 3 do: [ :each | obj ordered add: (Test new name: each printString)].

	^obj store; yourself
		
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testNiledDependentCollectionUnstore [

	"Verify a dependent collection's elements are still unstored with its owner, even if it has been nil'd out in its owner prior to the unstore"

	| test depIds |

	test := self _testCreateObjectWithCollection.
	depIds := test ordered collect: [ :each | each _id].

	test ordered: nil; unstore.

	self assert: ((Test storedInstancesIn: reStore) select: [ :each | depIds includes: each _id]) isEmpty
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testNiledDependentUnstore [

	"Verify a dependent object is still unstored with its owner, even if it has been nil'd out in its owner prior to the unstore"

	| test depId |

	test := self _testCreateObject.
	depId := test single2 _id.

	test single2: nil; unstore.

	self assert: ((Test storedInstancesIn: reStore) detect: [ :each | each _id = depId] ifNone: [nil]) isNil
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPostNiledDependentCollectionUnstoreTransaction [

	"Verify a dependent collection's elements are still unstored with its owner, even if it has been nil'd out in its owner prior to the unstore, subsequent to the owner's unstore"

	| test depIds |

	test := self _testCreateObjectWithCollection.
	depIds := test ordered collect: [ :each | each _id].

	reStore beginTransaction.
	test unstore; ordered: nil.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) select: [ :each | depIds includes: each _id]) isEmpty
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPostNiledDependentUnstoreTransaction [

	"Verify a dependent object is still unstored with its owner, even if it has been nil'd out in its owner in the same transaction, subsequent to the owner's unstore"

	| test depId |

	test := self _testCreateObject.
	depId := test single2 _id.

	reStore beginTransaction.
	test unstore; single2: nil.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) detect: [ :each | each _id = depId] ifNone: [nil]) isNil
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPostRemovedDependentCollectionUnstoreTransaction [

	"Verify a dependent collection's elements are still unstored with its owner, even if it has been changed to something else in its owner (i.e. removed from, but not nil'd) prior to the unstore, subsequent to the owner's unstore"

	| test depIds |

	test := self _testCreateObjectWithCollection.
	depIds := test ordered collect: [ :each | each _id].

	reStore beginTransaction.
	test unstore; ordered: OrderedCollection new.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) select: [ :each | depIds includes: each _id]) isEmpty
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPostRemovedDependentUnstoreTransaction [

	"Verify a dependent object is still unstored with its owner, even it has been changed to something else in its owner (i.e. removed from, but not nil'd) the same transaction, subsequent to the owner's unstore"

	| test depId |

	test := self _testCreateObject.
	depId := test single2 _id.

	reStore beginTransaction.
	test unstore; single2: Test new.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) detect: [ :each | each _id = depId] ifNone: [nil]) isNil
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPreNiledDependentCollectionUnstoreTransaction [

	"Verify a dependent collection's elements are still unstored with its owner, even if it has been nil'd out in its owner prior to the unstore, prior to the owner's unstore"

	| test depIds |

	test := self _testCreateObjectWithCollection.
	depIds := test ordered collect: [ :each | each _id].

	reStore beginTransaction.
	test ordered: nil; unstore.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) select: [ :each | depIds includes: each _id]) isEmpty
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPreNiledDependentUnstoreTransaction [

	"Verify a dependent object is still unstored with its owner, even if it has been nil'd out in its owner in the same transaction, prior to the owner's unstore"

	| test depId |

	test := self _testCreateObject.
	depId := test single2 _id.

	reStore beginTransaction.
	test single2: nil; unstore.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) detect: [ :each | each _id = depId] ifNone: [nil]) isNil
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPreRemovedDependentCollectionUnstoreTransaction [

	"Verify a dependent collection's elements are still unstored with its owner,  even if it has been changed to something else in its owner (i.e. removed from, but not nil'd) prior to the unstore, prior to the owner's unstore"

	| test depIds |

	test := self _testCreateObjectWithCollection.
	depIds := test ordered collect: [ :each | each _id].

	reStore beginTransaction.
	test ordered: OrderedCollection new; unstore.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) select: [ :each | depIds includes: each _id]) isEmpty
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testPreRemovedDependentUnstoreTransaction [

	"Verify a dependent object is still unstored with its owner, even if it has been changed to something else in its owner (i.e. removed from, but not nil'd) in the same transaction, prior to the owner's unstore"

	| test depId |

	test := self _testCreateObject.
	depId := test single2 _id.

	reStore beginTransaction.
	test single2: Test new; unstore.
	reStore commitTransaction.

	self assert: ((Test storedInstancesIn: reStore) detect: [ :each | each _id = depId] ifNone: [nil]) isNil
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testRemovedDependentCollectionUnstore [

	"Verify a dependent collection's elements are still unstored with its owner,  even if it has been changed to something else in its owner (i.e. removed from, but not nil'd) prior to the unstore"

	| test depIds |

	test := self _testCreateObjectWithCollection.
	depIds := test ordered collect: [ :each | each _id].

	test ordered: OrderedCollection new; unstore.

	self assert: ((Test storedInstancesIn: reStore) select: [ :each | depIds includes: each _id]) isEmpty
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testRemovedDependentUnstore [

	"Verify a dependent object is still unstored with its owner, even it has been changed to something else in its owner (i.e. removed from, but not nil'd) prior to the unstore"

	| test depId |

	test := self _testCreateObject.
	depId := test single2 _id.

	test single2: Test new; unstore.

	self assert: ((Test storedInstancesIn: reStore) detect: [ :each | each _id = depId] ifNone: [nil]) isNil
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testRollbackUnstorePostChange [

	"Verify changes made to an unstored object subseqeunt to it being unstored are rolled back as part of a rollback of the unstore"

	| test pre |

	test := self _testCreateObject.
	pre := test name.

	reStore beginTransaction.
	test unstore; name: pre, '_changed'.
	reStore rollbackTransaction.

	self assert: test name identicalTo: pre
]

{ #category : 'public' }
SSWReStoreUnstoreTests >> testRollbackUnstorePreChange [

	"Verify changes made to an unstored object prior to bit being unstored are rolled back as part of a rollback of the unstore"

	| test pre |

	test := self _testCreateObject.
	pre := test name.

	reStore beginTransaction.
	test name: pre, '_changed'; unstore.
	reStore rollbackTransaction.

	self assert: test name identicalTo: pre
]
