"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreMultiValueCacheDictionaryTest,
	#superclass : #SSWReStoreGenericTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreMultiValueCacheDictionaryTest >> componentDefinition [

	^Dictionary of: #key -> (OrderedCollection of: GenericOwnedTest dependent) 
]

{ #category : #accessing }
SSWReStoreMultiValueCacheDictionaryTest >> templateTestObject [

	| template |

	template := GenericTest new.
	template component: Dictionary new.

	#('Alan' 'Andrew' 'Anton' 'Barry' 'Bernard' 'Colin') do: 
		[ :name |
		template addToMultiKeyDictionary: (self testNamed: name)].

	^template

	
]

{ #category : #accessing }
SSWReStoreMultiValueCacheDictionaryTest >> testNamed: aString [

	^GenericOwnedTest new 
		name: aString; 
		key: (String with: aString first asLowercase);
		yourself
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testReadAllFetch [

	| testObjects queryCount |

	5 timesRepeat: [self createTestObject].
	reStore simulateReconnect.

	self assert: (self countQueriesDuring: [testObjects := (GenericTest storedInstancesIn: reStore) asOrderedCollection]) equals: 1.
	self assert: (self countQueriesDuring: [testObjects fetch: #component]) equals: 1.

	queryCount := self countQueriesDuring: 
		[testObjects do: 
			[ :obj |
			obj component do: 
				[ :values |
				self assert: (values allSatisfy: [ :each | each _isRecovered])]]].

	self assert: queryCount equals: 0
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testReadAllInclude [

	| testObjects queryCount |

	5 timesRepeat: [self createTestObject].
	reStore simulateReconnect.

	queryCount := self countQueriesDuring: [testObjects := (GenericTest storedInstancesIn: reStore) include: #component; asOrderedCollection].
	self assert: queryCount equals: 2. "1 for all GenericTests + 1 for all components"

	queryCount := self countQueriesDuring: 
		[testObjects do: 
			[ :obj |
			obj component do: 
				[ :values |
				self assert: (values allSatisfy: [ :each | each _isRecovered])]]].

	self assert: queryCount equals: 0
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshAdditionAtExistingKey [

	| clive |

	clive := self testNamed: 'Clive'.

	testObject2 addToMultiKeyDictionary: clive.
	testObject2 store.

	testObject refresh.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'c') size equals: 2.
	self assert: ((testObject component at: 'c') collect: [ :each | each name]) asSortedCollection asArray equals: #('Clive' 'Colin')
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshAdditionOfNewKey [

	| dave |

	dave := self testNamed: 'Dave'.

	testObject2 addToMultiKeyDictionary: dave.
	testObject2 store.

	testObject refresh.

	self assert: testObject component size equals: 4.
	self assert: (testObject component at: 'd') size equals: 1.
	self assert: (testObject component at: 'd') first equals: dave
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshRemovalAtExistingKey [

	| colin |

	colin := (testObject2 component at: 'c') removeFirst.

	testObject2 store.

	testObject refresh.

	self assert: testObject component size equals: 2.
	self deny: (testObject component includesKey: 'c').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = colin name]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshRemovalOfAllKeys [

	testObject2 component keys do: [ :each | testObject2 component removeKey: each].
	testObject2 store.

	testObject refresh.

	self assert: testObject component isEmpty.
	self assert: (GenericOwnedTest storedInstancesIn: reStore) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshRemovalOfKey [

	testObject2 component removeKey: 'b'.
	testObject2 store.

	testObject refresh.

	self assert: testObject component size equals: 2.
	self assert: testObject component keys asSortedCollection asArray = #('a' 'c').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name first asLowercase = $b]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshReplacementAtExistingKey [

	| bees barry bill |

	bees := testObject2 component at: 'b'.
	barry := bees remove: (bees detect: [ :each | each name = 'Barry']).
	bill := self testNamed: 'Bill'.
	testObject2 addToMultiKeyDictionary: bill.
	testObject2 store.

	testObject refresh.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'b') size equals: 2.
	self assert: ((testObject component at: 'b') collect: [ :each | each name]) asSortedCollection asArray equals: #('Bernard' 'Bill').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = barry name]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRefreshReplacementOfKey [

	testObject2 component removeKey: 'b'.
	testObject2 addToMultiKeyDictionary: (self testNamed: 'Bertram'); addToMultiKeyDictionary: (self testNamed: 'Bob').
	testObject2 store.

	testObject refresh.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'b') size equals: 2.
	self assert: ((testObject component at: 'b') collect: [ :each | each name]) asSortedCollection asArray equals: #('Bertram' 'Bob').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | (each name = 'Barry') | (each name = 'Bernard')]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackAdditionAtExistingKey [

	| clive |

	clive := self testNamed: 'Clive'.

	testObject addToMultiKeyDictionary: clive.
	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'c') size equals: 1.
	self assert: ((testObject component at: 'c') collect: [ :each | each name]) asSortedCollection asArray equals: #('Colin')
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackAdditionOfNewKey [

	| dave |

	dave := self testNamed: 'Dave'.

	testObject addToMultiKeyDictionary: dave.
	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: testObject component keys asSortedCollection asArray equals: #('a' 'b' 'c')
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackRemovalAtExistingKey [

	| colin |

	colin := (testObject component at: 'c') removeFirst.

	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: (testObject component includesKey: 'c').
	self assert: ((testObject component at: 'c') collect: [ :each | each name]) asSortedCollection asArray equals: #('Colin').
	self deny: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = colin name]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackRemovalOfAllKeys [

	testObject component keys do: [ :each | testObject component removeKey: each].
	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: testObject component keys asSortedCollection asArray = #('a' 'b' 'c').
	self deny: (GenericOwnedTest storedInstancesIn: reStore) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackRemovalOfKey [

	testObject component removeKey: 'b'.
	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: (testObject component includesKey: 'b').
	self assert: testObject component keys asSortedCollection asArray = #('a' 'b' 'c').
	self deny: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name first asLowercase = $b]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackReplacementAtExistingKey [

	| barry bill |

	barry := (testObject component at: 'b') removeFirst.
	bill := self testNamed: 'Bill'.
	testObject addToMultiKeyDictionary: bill.
	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'b') size equals: 2.
	self assert: ((testObject component at: 'b') collect: [ :each | each name]) asSortedCollection asArray equals: #('Barry' 'Bernard').
	self deny: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = barry name]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testRollbackReplacementOfKey [

	testObject component removeKey: 'b'.
	testObject addToMultiKeyDictionary: (self testNamed: 'Bertram'); addToMultiKeyDictionary: (self testNamed: 'Bob').
	testObject rollback.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'b') size equals: 2.
	self assert: ((testObject component at: 'b') collect: [ :each | each name]) asSortedCollection asArray equals: #('Barry' 'Bernard').
	self deny: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = 'Barry']) isEmpty.
	self deny: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = 'Bernard']) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreAdditionAtExistingKey [

	| clive |

	clive := self testNamed: 'Clive'.

	testObject addToMultiKeyDictionary: clive.
	testObject store.

	self fetchTestObjects.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'c') size equals: 2.
	self assert: ((testObject component at: 'c') collect: [ :each | each name]) asSortedCollection asArray equals: #('Clive' 'Colin')
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreAdditionOfNewKey [

	| dave |

	dave := self testNamed: 'Dave'.

	testObject addToMultiKeyDictionary: dave.
	testObject store.

	self fetchTestObjects.

	self assert: testObject component size equals: 4.
	self assert: (testObject component at: 'd') size equals: 1.
	self assert: (testObject component at: 'd') first equals: dave
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreRemovalAtExistingKey [

	| colin |

	colin := (testObject component at: 'c') removeFirst.

	testObject store.
	self fetchTestObjects.

	self assert: testObject component size equals: 2.
	self deny: (testObject component includesKey: 'c').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = colin name]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreRemovalOfAllKeys [

	testObject component keys do: [ :each | testObject component removeKey: each].
	testObject store.

	self fetchTestObjects.

	self assert: testObject component isEmpty.
	self assert: (GenericOwnedTest storedInstancesIn: reStore) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreRemovalOfKey [

	testObject component removeKey: 'b'.
	testObject store.

	self fetchTestObjects.

	self assert: testObject component size equals: 2.
	self assert: testObject component keys asSortedCollection asArray = #('a' 'c').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name first asLowercase = $b]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreReplacementAtExistingKey [

	| bees barry bill |

	bees := testObject component at: 'b'.
	barry := bees remove: (bees detect: [ :each | each name = 'Barry']).
	bill := self testNamed: 'Bill'.
	testObject addToMultiKeyDictionary: bill.
	testObject store.

	self fetchTestObjects.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'b') size equals: 2.
	self assert: ((testObject component at: 'b') collect: [ :each | each name]) asSortedCollection asArray equals: #('Bernard' 'Bill').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | each name = barry name]) isEmpty
]

{ #category : #'unit tests' }
SSWReStoreMultiValueCacheDictionaryTest >> testStoreReplacementOfKey [

	testObject component removeKey: 'b'.
	testObject addToMultiKeyDictionary: (self testNamed: 'Bertram'); addToMultiKeyDictionary: (self testNamed: 'Bob').
	testObject store.

	self fetchTestObjects.

	self assert: testObject component size equals: 3.
	self assert: (testObject component at: 'b') size equals: 2.
	self assert: ((testObject component at: 'b') collect: [ :each | each name]) asSortedCollection asArray equals: #('Bertram' 'Bob').
	self assert: ((GenericOwnedTest storedInstancesIn: reStore) select: [ :each | (each name = 'Barry') | (each name = 'Bernard')]) isEmpty
]
