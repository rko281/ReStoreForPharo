Class {
	#name : #SSWReStoreDirectlyPersistedTest,
	#superclass : #SSWReStore2Test,
	#instVars : [
		'owner'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testCollection: aSymbol [

	| collection |

	collection := owner perform: aSymbol.
	aSymbol = #sortedCollection ifFalse: [collection := collection asSortedCollection].

	self assert: collection size equals: 8.
	self assert: (collection collect: [ :each | each value]) asArray equals: #(1 2 3 4 5 6 7 8).
	self assert: collection asArray equals: ((1 to: 8) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testCollectionMutationCommit: aSymbol [

	| collection |

	collection := owner perform: aSymbol.
	collection do: [ :each | each bitSet: 8].

	owner store.

	reStore simulateReconnect.
	self reReadTestData.
	collection := owner perform: aSymbol.
	aSymbol = #sortedCollection ifFalse: [collection := collection asSortedCollection].

	self assert: (collection collect: [ :each | each value]) asArray equals: #(129 130 131 132 133 134 135 136).
	self assert: collection asArray equals: ((129 to: 136) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testCollectionMutationHasChanged: aSymbol [

	| collection |

	collection := owner perform: aSymbol.
	self deny: owner hasChanged.
	self deny: collection hasChanged.

	collection do: [ :each | each bitSet: 8].

	self assert: owner hasChanged.
	self assert: collection hasChanged.
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testCollectionMutationRefresh: aSymbol [

	| owner2 collection |

	owner2 := (reStore2 instancesOf: TestWithBitmask) first.
	(owner2 perform: aSymbol) do: [ :each | each bitSet: 8].
	owner2 store.

	self refreshDelay.

	self _testCollection: aSymbol.
	owner refresh.
	collection := owner perform: aSymbol.
	aSymbol = #sortedCollection ifFalse: [collection := collection asSortedCollection].

	self assert: (collection collect: [ :each | each value]) asArray equals: #(129 130 131 132 133 134 135 136).
	self assert: collection asArray equals: ((129 to: 136) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testCollectionMutationRollback: aSymbol [

	| collection |

	collection := owner perform: aSymbol.
	collection do: [ :each | each bitSet: 8].

	owner rollback.

	self _testCollection: aSymbol
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testSequenceableCollectionCommit: aSymbol [

	| collection |

	collection := owner perform: aSymbol.
	collection removeFirst; removeFirst; removeLast; removeLast; removeLast; add: (TestBitmask new value: 99).
	owner store.

	reStore simulateReconnect.
	self reReadTestData.
	collection := owner perform: aSymbol.

	self assert: collection size equals: 4.
	self assert: (collection collect: [ :each | each value]) asArray equals: #(3 4 5 99).
	self assert: collection asArray equals: (#(3 4 5 99) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testSequenceableCollectionRefresh: aSymbol [

	| owner2 collection |

	owner2 := (reStore2 instancesOf: TestWithBitmask) first.
	(owner2 perform: aSymbol) removeFirst; removeFirst; removeLast; removeLast; removeLast; add: (TestBitmask new value: 99).
	owner2 store.

	self refreshDelay.
	self _testCollection: aSymbol.

	owner refresh.
	collection := owner perform: aSymbol.

	self assert: collection size equals: 4.
	self assert: (collection collect: [ :each | each value]) asArray equals: #(3 4 5 99).
	self assert: collection asArray equals: (#(3 4 5 99) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> _testSequenceableCollectionRollback: aSymbol [

	| collection |

	collection := owner perform: aSymbol.

	collection removeFirst; removeFirst; removeLast; removeLast.
	collection last value: 99.
	self assert: collection size equals: 4.
	self assert: (collection collect: [ :each | each value]) asArray equals: #(3 4 5 99).
	self assert: collection asArray equals: (#(3 4 5 99) collect: [ :each | TestBitmask value: each]).

	owner rollback.

	self _testCollection: aSymbol
]

{ #category : #running }
SSWReStoreDirectlyPersistedTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.

	aReStore addClass: TestWithBitmask
]

{ #category : #running }
SSWReStoreDirectlyPersistedTest >> createTestData [

	| collection dictionary |

	collection := (1 to: 8) collect: [ :each | TestBitmask value: each].
	dictionary := Dictionary new.
	collection do: [ :each | dictionary at: each put: (each copy bitSet: 9)].

	owner := 
		TestWithBitmask new 
			name: 'owner'; 
			orderedCollection: collection asOrderedCollection;
			sortedCollection: collection asSortedCollection;
			array: collection asArray;
			set: collection asSet;
			dictionary: dictionary;
			storeIn: reStore; 
			yourself
]

{ #category : #running }
SSWReStoreDirectlyPersistedTest >> reReadTestData [

	owner := (TestWithBitmask storedInstancesIn: reStore) detect: [ :each | each name = 'owner']
]

{ #category : #helpers }
SSWReStoreDirectlyPersistedTest >> storeNewOwnersWithBitmaskValues: aCollection [

	^(aCollection collect: 
		[ :each |
		TestWithBitmask new 
			bitmask: (TestBitmask value: each);
			yourself]) storeAllIn: reStore; yourself
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArray [

	self _testCollection: #array
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayCommit [

	| collection |

	collection := owner array.
	collection at: 1 put: nil; at: 8 put: (TestBitmask new value: 99).
	owner store.

	reStore simulateReconnect.
	self reReadTestData.
	collection := owner array.

	self assert: collection size equals: 8.
	self assert: (collection collect: [ :each | each ifNotNil: [each value]]) asArray equals: #(nil 2 3 4 5 6 7 99).
	self assert: collection asArray equals: (#(nil 2 3 4 5 6 7 99) collect: [ :each | each ifNotNil: [TestBitmask value: each]])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayMutationCommit [

	self _testCollectionMutationCommit: #array
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayMutationHasChanged [

	self _testCollectionMutationHasChanged: #array
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayMutationRefresh [

	self _testCollectionMutationRefresh: #array
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayMutationRollback [

	self _testCollectionMutationRollback: #array
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayRefresh [

	| owner2 collection |

	owner2 := (reStore2 instancesOf: TestWithBitmask) first.
	owner2 array at: 1 put: nil; at: 8 put: (TestBitmask new value: 99).
	owner2 store.

	self refreshDelay.
	self testSet.
	owner refresh.
	collection := owner array.

	self assert: collection size equals: 8.
	self assert: (collection collect: [ :each | each ifNotNil: [each value]]) asArray equals: #(nil 2 3 4 5 6 7 99).
	self assert: collection asArray equals: (#(nil 2 3 4 5 6 7 99) collect: [ :each | each ifNotNil: [TestBitmask value: each]])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testArrayRollback [

	owner array at: 1 put: nil; at: 8 put: (TestBitmask new value: 99).
	owner rollback.

	self testArray
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testAutoRefresh [

	self assert: owner bitmask value equals: 0.

	(reStore2 instancesOf: TestWithBitmask) first 
		bitmask: (TestBitmask value: 99);
		store.

	self refreshDelay.

	"Re-reading after a rollback will perform an auto refresh"
	reStore rollbackTransaction.
	(reStore instancesOf: TestWithBitmask) first.

	self assert: owner isDBProxy.
	self assert: owner _proxiedObject bitmask value equals: 99.
	self assert: owner _copyObject bitmask value equals: 99.

]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testCollectQuery [

	| instances |

	self storeNewOwnersWithBitmaskValues: (1 to: 8).

	instances := TestWithBitmask storedInstancesIn: reStore.
	self assert: (instances collect: [ :each | each bitmask]) asArray equals: ((0 to: 8) collect: [ :each | TestBitmask new value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testCollectQueryOnValue [

	| instances |

	self storeNewOwnersWithBitmaskValues: (1 to: 8).

	instances := TestWithBitmask storedInstancesIn: reStore.
	self assert: (instances collect: [ :each | each bitmask value]) asArray equals: (0 to: 8) asArray
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testCollectQueryWithMethod [

	| instances |

	self storeNewOwnersWithBitmaskValues: (1 to: 8).

	instances := TestWithBitmask storedInstancesIn: reStore.
	self assert: (instances collect: [ :each | each bitmask isBitSet: 1]) asArray equals: ((0 to: 8) collect: [ :each | each isBitSet: 1]).
	self assert: (instances collect: [ :each | each bitmask isBitSet: 2]) asArray equals: ((0 to: 8) collect: [ :each | each isBitSet: 2])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testCommit [

	self assert: owner bitmask value equals: 0.

	owner bitmask: (TestBitmask value: 99).
	owner store.

	reStore simulateReconnect.
	self reReadTestData.

	self assert: owner bitmask value equals: 99
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testDeletedObjectRecovery [

	"Verify recovery of a deleted object containing a mutable directly persisted object (previously caused an error)"

	| person table |

	reStore addClass: SimplePerson.
	table := reStore tableForClass: SimplePerson.
	(table fieldAccessing: #friend) targetClass: TestWithBitmask.
	reStore synchronizeClass: SimplePerson.

	person := SimplePerson new friend: owner.
	person storeIn: reStore.
	self shouldnt: [owner unstore] raise: Error.

	reStore simulateReconnect.

	person := (SimplePerson storedInstancesIn: reStore) first.
	self assert: person friend isDBDeleted.
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testDictionary [

	self assert: owner dictionary size equals: 8.

	self assert: (owner dictionary keys collect: [ :each | each value]) asSortedCollection asArray equals: #(1 2 3 4 5 6 7 8).
	self assert: owner dictionary keys asSortedCollection asArray equals: ((1 to: 8) collect: [ :each | TestBitmask value: each]).

	self assert: (owner dictionary values collect: [ :each | each value]) asSortedCollection asArray equals: #(257 258 259 260 261 262 263 264).
	self assert: owner dictionary values asSortedCollection asArray equals: ((257 to: 264) collect: [ :each | TestBitmask value: each]).

	owner dictionary keysAndValuesDo: [ :key :value | self assert: value value equals: key value + 256]
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testDictionaryCommit [

	owner dictionary removeKey: (TestBitmask value: 1); removeKey: (TestBitmask value: 2); removeKey: (TestBitmask value: 6); removeKey: (TestBitmask value: 7); removeKey: (TestBitmask value: 8); at: (TestBitmask value: 9) put: (TestBitmask value: 265).
	owner store.

	reStore simulateReconnect.
	self reReadTestData.

	self assert: owner dictionary size equals: 4.

	self assert: (owner dictionary keys collect: [ :each | each value]) asSortedCollection asArray equals: #(3 4 5 9).
	self assert: owner dictionary keys asSortedCollection asArray equals: (#(3 4 5 9) collect: [ :each | TestBitmask value: each]).

	self assert: (owner dictionary values collect: [ :each | each value]) asSortedCollection asArray equals: #(259 260 261 265).
	self assert: owner dictionary values asSortedCollection asArray equals: (#(259 260 261 265) collect: [ :each | TestBitmask value: each]).

	owner dictionary keysAndValuesDo: [ :key :bitmask | self assert: bitmask value equals: key value + 256]
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testDictionaryMutationCommit [

	(owner dictionary at: (TestBitmask value: 1)) bitSet: 8.
	(owner dictionary at: (TestBitmask value: 8)) bitSet: 10.
	owner store.

	reStore simulateReconnect.
	self reReadTestData.

	self assert: owner dictionary size = 8.

	owner dictionary keysAndValuesDo: 
		[ :key :bitmask | 
		key value = 1
		ifTrue: 
			[self assert: bitmask value equals: (1+256+128)]
		ifFalse: 
			[key value = 8
				ifTrue: [self assert: bitmask value equals: (8 + 256 + 512)]
				ifFalse: [self assert: bitmask value equals: key value + 256]]]
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testDictionaryMutationHasChanged [

	self deny: owner hasChanged.
	self deny: owner dictionary hasChanged.

	(owner dictionary at: (TestBitmask value: 1)) bitSet: 8.

	self assert: owner hasChanged.
	self assert: owner dictionary hasChanged.
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testDictionaryRollback [

	owner dictionary removeKey: (TestBitmask value: 1); removeKey: (TestBitmask value: 2); removeKey: (TestBitmask value: 7); removeKey: (TestBitmask value: 8).
	(owner dictionary at: (TestBitmask value: 6)) value: 999.

	self assert: owner dictionary size equals: 4.
	self assert: (owner dictionary keys collect: [ :each | each value]) asSortedCollection asArray equals: #(3 4 5 6).
	self assert: owner dictionary keys asSortedCollection asArray equals: (#(3 4 5 6) collect: [ :each | TestBitmask value: each]).

	self assert: (owner dictionary values collect: [ :each | each value]) asSortedCollection asArray equals: #(259 260 261 999).
	self assert: owner dictionary values asSortedCollection asArray equals: (#(259 260 261 999) collect: [ :each | TestBitmask value: each]).

	owner dictionary keysAndValuesDo: 
		[ :key :bitmask | 
		key value = 6
			ifTrue: [self assert: bitmask value equals: 999]
			ifFalse: [self assert: bitmask value equals: key value + 256]].

	owner rollback.

	self testDictionary
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testHasChanged [

	self deny: owner hasChanged.

	owner bitmask bitSet: 1.

	self assert: owner hasChanged.
	owner store.
	self deny: owner hasChanged.

	owner bitmask bitSet: 2.
	self assert: owner hasChanged.
	owner store.
	self deny: owner hasChanged
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testMutationCommit [

	self assert: owner bitmask value equals: 0.

	owner bitmask bitSet: 3.
	owner store.

	reStore simulateReconnect.
	self reReadTestData.

	self assert: owner bitmask value equals: 4
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testMutationRollback [

	self assert: owner bitmask value equals: 0.

	owner bitmask bitSet: 2.
	owner rollback.

	self assert: owner bitmask value equals: 0
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollection [

	self _testCollection: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionCommit [

	self _testSequenceableCollectionCommit: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionMutationCommit [

	self _testCollectionMutationCommit: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionMutationHasChanged [

	self _testCollectionMutationHasChanged: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionMutationRefresh [

	self _testCollectionMutationRefresh: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionMutationRollback [

	self _testCollectionMutationRollback: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionRefresh [

	self _testSequenceableCollectionRefresh: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testOrderedCollectionRollback [

	self _testSequenceableCollectionRollback: #orderedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testQuery [

	| newOwners instances |

	newOwners := self storeNewOwnersWithBitmaskValues: (1 to: 8).

	instances := TestWithBitmask storedInstancesIn: reStore.

	self assert: (instances select: [ :each | each bitmask = (TestBitmask new value: 0)]) size equals: 1.
	self assert: (instances detect: [ :each | each bitmask = (TestBitmask new value: 0)]) identicalTo: owner.
	self assert: (instances detect: [ :each | each bitmask = (TestBitmask new value: 8)]) identicalTo: newOwners last
	
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testQueryByExample [

	| template matches |

	self storeNewOwnersWithBitmaskValues: (1 to: 8).
	self storeNewOwnersWithBitmaskValues: (1 to: 4).

	template := TestWithBitmask new.

	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first identicalTo: owner.

	template bitmask value: 4.
	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 2.
	self assert: (matches allSatisfy: [ :each | each bitmask value = 4]).

	template bitmask value: 8.
	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first bitmask value equals: 8.

	template bitmask value: 16.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty.

	template bitmask: nil required.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty.

	owner bitmask: nil; store.
	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first identicalTo: owner
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testQueryOnValue [

	| newOwners instances |

	newOwners := self storeNewOwnersWithBitmaskValues: (1 to: 8).

	instances := TestWithBitmask storedInstancesIn: reStore.

	self assert: (instances select: [ :each | each bitmask value = 0]) size equals: 1.
	self assert: (instances detect: [ :each | each bitmask value = 0]) identicalTo: owner.
	self assert: (instances detect: [ :each | each bitmask value = 8]) identicalTo: newOwners last
	
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testQueryWithMethod [

	| newOwners instances |

	newOwners := self storeNewOwnersWithBitmaskValues: (1 to: 8).

	instances := TestWithBitmask storedInstancesIn: reStore.

	self assert: (instances select: [ :each | each bitmask isBitSet: 1]) size equals: 4.
	self assert: (instances select: [ :each | each bitmask isBitSet: 4]) size equals: 1.
	self assert: (instances detect: [ :each | each bitmask isBitSet: 4]) identicalTo: newOwners last	
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testRefresh [

	self assert: owner bitmask value equals: 0.

	(reStore2 instancesOf: TestWithBitmask) first 
		bitmask: (TestBitmask value: 99);
		store.

	self refreshDelay.

	self assert: owner bitmask value equals: 0.
	owner refresh.

	self assert: owner isDBProxy.
	self assert: owner _proxiedObject bitmask value equals: 99.
	self assert: owner _copyObject bitmask value equals: 99.

]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testRollback [

	self assert: owner bitmask value equals: 0.

	owner bitmask: (TestBitmask value: 99).
	owner rollback.

	self assert: owner bitmask value equals: 0
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSet [

	self _testCollection: #set
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetCommit [

	| collection |

	collection := owner set.
	#(1 2 6 7 8) do: [ :each | collection remove: (TestBitmask value: each)].
	collection add: (TestBitmask value: 99).
	owner store.

	reStore simulateReconnect.
	self reReadTestData.
	collection := owner set asSortedCollection.

	self assert: collection size equals: 4.
	self assert: (collection collect: [ :each | each value]) asArray equals: #(3 4 5 99).
	self assert: collection asArray equals: (#(3 4 5 99) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetMutationCommit [

	self _testCollectionMutationCommit: #set
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetMutationHasChanged [

	self _testCollectionMutationHasChanged: #set
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetMutationRefresh [

	self _testCollectionMutationRefresh: #set
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetMutationRollback [

	self _testCollectionMutationRollback: #set
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetRefresh [

	| owner2 collection |

	owner2 := (reStore2 instancesOf: TestWithBitmask) first.
	collection := owner2 set.
	#(1 2 6 7 8) do: [ :each | collection remove: (TestBitmask value: each)].
	collection add: (TestBitmask value: 99).
	owner2 store.

	self refreshDelay.
	self testSet.
	owner refresh.
	collection := owner set asSortedCollection.

	self assert: collection size equals: 4.
	self assert: (collection collect: [ :each | each value]) asArray equals: #(3 4 5 99).
	self assert: collection asArray equals: (#(3 4 5 99) collect: [ :each | TestBitmask value: each])
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSetRollback [

	| collection |

	collection := owner set.
	#(1 2 6 7 8) do: [ :each | collection remove: (TestBitmask value: each)].
	collection add: (TestBitmask value: 99).
	owner rollback.

	self testSet
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollection [

	self _testCollection: #sortedCollection.

	"Also verify sorting"
	owner sortedCollection add: (TestBitmask value: -1).
	owner store.

	reStore simulateReconnect.
	self reReadTestData.

	self assert: owner sortedCollection first value equals: -1
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionCommit [

	self _testSequenceableCollectionCommit: #sortedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionMutationCommit [

	self _testCollectionMutationCommit: #sortedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionMutationHasChanged [

	self _testCollectionMutationHasChanged: #sortedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionMutationRefresh [

	self _testCollectionMutationRefresh: #sortedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionMutationRollback [

	self _testCollectionMutationRollback: #sortedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionRefresh [

	self _testSequenceableCollectionRefresh: #sortedCollection
]

{ #category : #'unit tests' }
SSWReStoreDirectlyPersistedTest >> testSortedCollectionRollback [

	self _testSequenceableCollectionRollback: #sortedCollection
]
