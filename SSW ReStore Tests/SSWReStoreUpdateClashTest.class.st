"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreUpdateClashTest,
	#superclass : #SSWReStore2Test,
	#category : #'SSW ReStore Tests'
}

{ #category : #Running }
SSWReStoreUpdateClashTest >> createTestData [

	self createStandardTestInstance.
	reStore simulateReconnect.
	self refreshDelay
]

{ #category : #Running }
SSWReStoreUpdateClashTest >> prvTestOwnerTest: anOwnerTest in: aReStore [

	| oldName oldNumber |

	oldName := anOwnerTest name.
	oldNumber := anOwnerTest number.

	self deny: aReStore isTransactionInProgress.
	self deny: anOwnerTest hasChanged.

	anOwnerTest name: ('xxx', oldName, 'xxx').
	self assert: anOwnerTest hasChanged.
	anOwnerTest rollback.
	self deny: anOwnerTest hasChanged.
	self assert: anOwnerTest name = oldName.

	anOwnerTest number: (oldNumber + 123).
	self assert: anOwnerTest hasChanged.
	anOwnerTest rollback.
	self deny: anOwnerTest hasChanged.
	self assert: (anOwnerTest number = oldNumber).

	anOwnerTest name: ('xxx', oldName, 'xxx').
	anOwnerTest store.
	self deny: anOwnerTest hasChanged.

	anOwnerTest number: (oldNumber + 123).
	anOwnerTest store.
	self deny: anOwnerTest hasChanged.

	anOwnerTest refresh.
	self assert: (anOwnerTest name = ('xxx', oldName, 'xxx')).
	self assert: (anOwnerTest number = (oldNumber + 123))
]

{ #category : #Running }
SSWReStoreUpdateClashTest >> prvTestTest: aTest in: aReStore [

	| oldName |

	oldName := aTest name.

	self deny: aTest hasChanged.

	aTest name: ('xxx', oldName, 'xxx').
	self assert: aTest hasChanged.

	aTest rollback.
	self deny: aTest hasChanged.
	self assert: aTest name = oldName.

	aTest name: ('xxx', oldName, 'xxx').
	self assert: aTest store.
	self deny: aTest hasChanged.

	aTest refresh.
	self assert: (aTest name = ('xxx', oldName, 'xxx'))
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test01DetectAndMerge [

	"Check detect and pass (independent changes)"

	| inst1 inst2 origName |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	origName := inst1 name.

	self assert: (reStore evaluateAsTransaction: [inst1 number: 11]).
	self assert: (reStore2 evaluateAsTransaction: [inst2 name: 'test1:2']).

	self assert: (inst1 isDBProxy).
	self assert: (inst1 _proxiedObject number = 11).		"Change persisted"
	self assert: (inst1 _copyObject number = 11).		"...and copied"
	self assert: (inst1 _proxiedObject name = origName).	"Change not picked up till refresh"
	self assert: (inst1 _copyObject name = origName).	"Changed not picked up till refresh"

	self assert: (inst2 isDBProxy).
	self assert: (inst2 _proxiedObject number = 11).		"Change in session1 picked up and merged"
	self assert: (inst2 _copyObject number = 11).		"...and copied"
	self assert: (inst2 _proxiedObject name = 'test1:2').	"Change persisted"
	self assert: (inst2 _copyObject name = 'test1:2').	"...and copied"

	self refreshDelay.
	reStore refreshAllObjects. 
	reStore2 refreshAllObjects. 

	self assert: (inst1 number = 11).
	self assert: (inst1 name = 'test1:2').
	self assert: (inst2 number = 11).
	self assert: (inst2 name = 'test1:2').

	self prvTestOwnerTest: inst2 in: reStore2
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test02DetectNoMerge [

	"Check detect and fail (independent changes but merge prevented)"
	
	| inst1 inst2 oldNumber |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	oldNumber := inst1 number.

	"OwnerTest blocks updates on instances with this name..."
	self assert: (reStore evaluateAsTransaction: [inst1 name: 'blockMerge']).
	"...so the following will fail"
	self deny: (reStore2 evaluateAsTransaction: [inst2 number: 99]). 

	reStore2 rollbackAndRefreshTransaction.
	self deny: (reStore2 hasTransaction).
	self assert: (inst2 isDBProxy).
	self assert: (inst2 name = 'blockMerge').
	self assert: (inst2 number = oldNumber).
	
	reStore refreshAllObjects.

	self assert: (inst1 name = 'blockMerge').
	self assert: (inst2 number = oldNumber).
	self assert: (inst2 name = 'blockMerge').

	self prvTestOwnerTest: inst2 in: reStore2
	
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test03DetectFailRollback [

	"Check detect-fail-rollback"

	| inst1 inst2 oldSingle |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	oldSingle := inst2 single1 name.

	self assert: (reStore evaluateAsTransaction: [inst1 name: 'test2:1']).
	self deny: (reStore2 evaluateAsTransaction: [inst2 name: 'test2:2'. inst2 single1 name: 'single2:2']).

	reStore2 rollbackAndRefreshTransaction.
	self deny: (reStore2 hasTransaction).
	self assert: (inst1 isDBProxy).
	self assert: (inst2 isDBProxy).
	self assert: (inst2 name = 'test2:1').
	self assert: (inst2 single1 name = oldSingle).

	reStore refreshAllObjects.

	self assert: (inst1 name = 'test2:1').
	self assert: (inst2 name = 'test2:1').
	self deny: (inst2 name = 'single2:2').

	self prvTestOwnerTest: inst2 in: reStore2.
	self prvTestTest: inst2 single1 in: reStore2
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test04DetectFailRollforward [

	"Check detect-fail-rollforward"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (reStore evaluateAsTransaction: [inst1 name: 'test3:1']).
	self deny: (reStore2 evaluateAsTransaction: [inst2 name: 'test3:2'. inst2 single1 name: 'single3:2']).

	reStore2 refreshAndRollforwardTransaction.
	self assert: (reStore2 commitTransaction).

	self assert: (inst1 isDBProxy).
	self assert: (inst2 isDBProxy).
	self assert: (inst2 single1 isDBProxy).

	reStore simulateReconnect.
	reStore2 simulateReconnect.

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	
	"self refreshDelay."

	self assert: (inst1 name = 'test3:2').
	self assert: (inst2 name = 'test3:2').
	self assert: (inst2 single1 name = 'single3:2')
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test05DetectFailAndHandle [

	"Check detect-fail-handle-pass"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	inst1 single1 name.
	inst2 single1 name.

	self assert: (reStore evaluateAsTransaction: [inst1 single1 name: 'single4:1']).
	self assert: (reStore2 evaluateAsTransaction: [inst2 name: 'test4:2'. inst2 single1 name: 'single4:2']).

	self assert: (inst1 isDBProxy).
	self assert: (inst1 isDBProxy).
	self assert: (inst1 single1 isDBProxy).
	self assert: (inst1 single1 _proxiedObject name = 'single4:1').	"Change not picked up till refresh"
	self assert: (inst1 single1 _copyObject name = 'single4:1').		"Change not picked up till refresh"

	self assert: (inst2 single1 isDBProxy).
	self assert: (inst2 single1 _proxiedObject name = 'single4:2 (overriden single4:1)').  "Clash handled"
	self assert: (inst2 single1 _copyObject name = 'single4:2 (overriden single4:1)').	"...and copied"

	self refreshDelay.
	reStore refreshAllObjects.
	reStore2 refreshAllObjects.

	self assert: (inst1 single1 name = 'single4:2 (overriden single4:1)').
	self assert: (inst2 single1 name = 'single4:2 (overriden single4:1)').
	self assert: (inst2 name = 'test4:2')
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test06DetectFailNoHandle [

	"Check detect-fail-handle-fail"

	| inst1 inst2 oldName oldSingle |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	inst1 single1 name.
	oldName := inst2 name.
	oldSingle := inst2 single1 name.

	self assert: (reStore evaluateAsTransaction: [inst1 name: 'test5:1'. inst1 single1 name: 'BLOCK5:1']).
	self deny: (reStore2 evaluateAsTransaction: [inst2 name: 'test5:2'. inst2 single1 name: 'single5:2']).
	reStore2 rollbackTransaction.

	self assert: (inst1 isDBProxy).
	self assert: (inst2 isDBProxy).
	self assert: (inst1 single1 isDBProxy).
	self assert: (inst2 name = oldName).
	self assert: (inst2 single1 isDBProxy).
	self assert: (inst2 single1 _proxiedObject name = oldSingle).
	self assert: (inst2 single1 _copyObject name = oldSingle).

	self refreshDelay.
	reStore refreshAllObjects.
	reStore2 refreshAllObjects.

	self assert: (inst1 single1 name = 'BLOCK5:1').
	self assert: (inst2 single1 name = 'BLOCK5:1').
	self assert: (inst2 name = 'test5:1').

	self prvTestOwnerTest: inst2 in: reStore2.
	self prvTestTest: inst2 single1 in: reStore2
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test07DetectFailWithDeleteRollback [

	"Check detect-fail handling of transaction with a deletion (previously handled incorrectly)"

	| inst1 inst2 single2 cls id |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	single2 := inst2 single1.
	cls := single2 class.
	id := single2 _id.

	self assert: (reStore evaluateAsTransaction: [inst1 name: 'test7:1']).
	self deny: (reStore2 evaluateAsTransaction: [inst2 name: 'test7:2'. inst2 single1 unstore]).

	"Check internal state - previously the failed unstored proxy was lost"
	self assert: (reStore2 cachedObjectOfClass: cls withID: id ifAbsent: [nil]) == single2.

	reStore2 rollbackTransaction.

	self assert: single2 isPersistent.
	self deny: single2 _dbProxy _isDeleted.
	self assert: ((cls storedInstancesIn: reStore2) detect: [ :each | each _id = id]) == single2
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test08DetectFailWithDeleteRollforward [

	"Check detect-fail-rollforward handling of transaction with a deletion (previously handled incorrectly)"

	| inst1 inst2 single2 cls id |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	single2 := inst2 single1.
	cls := single2 class.
	id := single2 _id.

	self assert: (reStore evaluateAsTransaction: [inst1 name: 'test8:1']).
	self deny: (reStore2 evaluateAsTransaction: [inst2 name: 'test8:2'. inst2 single1 unstore]).

	"Check internal state - previously the failed unstored proxy was lost"
	self assert: (reStore2 cachedObjectOfClass: cls withID: id ifAbsent: [nil]) == single2.

	reStore2 refreshAndRollforwardTransaction; commitTransaction.

	self deny: inst2 single1 isPersistent.
	self deny: ((inst2 single1 class storedInstancesIn: reStore2) anySatisfy: [ :each | each _id = id])
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test10ObjectNextIDClash [

	"Check update clashes to the NEXT_ID table are correctly handled, and without failing the transaction"

	| record1 record2 nextID obj1 obj2 |

	record1 := reStore tableRecordFor: (reStore tableForClass: Test).
	record2 := reStore2 tableRecordFor: (reStore2 tableForClass: Test).

	self assert: record1 nextID equals: record2 nextID.

	"Create new instances in both reStores; ensure commits succeed and nextIDs are updated accordingly in the order of commit"
	nextID := record1 nextID.
	obj1 := Test new name: 'one'.
	obj2 := Test new name: 'two'.

	self assert: (obj1 storeIn: reStore).
	self assert: (obj2 storeIn: reStore2).

	self assert: obj1 _id equals: nextID.
	self assert: obj2 _id equals: nextID + 1.

	self assert: record1 nextID equals: nextID + 1.
	self assert: record2 nextID equals: nextID + 2.

	"Try again reversing order"
	nextID := record2 nextID. "record2 is most up-to-date"
	obj1 := Test new name: 'three'.
	obj2 := Test new name: 'four'.

	self assert: (obj2 storeIn: reStore2).
	self assert: (obj1 storeIn: reStore).

	self assert: obj2 _id equals: nextID.
	self assert: obj1 _id equals: nextID + 1.

	self assert: record2 nextID equals: nextID + 1.
	self assert: record1 nextID equals: nextID + 2
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test11CollectionNextIDClash [

	"Check update clashes to the NEXT_ID table for collection tables are correctly handled, and without failing the transaction"

	| inst1 inst2 record1 record2 nextID |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	record1 := reStore tableRecordFor: ((reStore tableForClass: OwnerTest) collectionAccessing: #ordered) collectionTable.
	record2 := reStore2 tableRecordFor: ((reStore2 tableForClass: OwnerTest) collectionAccessing: #ordered) collectionTable.

	self assert: record1 nextID equals: record2 nextID.

	"Add new instances in both reStores; ensure commits succeed and nextIDs are updated accordingly in the order of commit"
	nextID := record1 nextID.
	inst1 ordered add: (Test new name: 'one').
	inst2 ordered add: (Test new name: 'two').

	self assert: inst1 store.
	self assert: inst2 store.

	self assert: inst1 ordered _collectionEntries last entryID equals: nextID.
	self assert: inst2 ordered _collectionEntries last entryID equals: nextID + 1.

	self assert: record1 nextID equals: nextID + 1.
	self assert: record2 nextID equals: nextID + 2.

	"Try again reversing order"
	nextID := record2 nextID. "record2 is most up-to-date"
	inst1 ordered add: (Test new name: 'one').
	inst2 ordered add: (Test new name: 'two').

	self assert: inst2 store.
	self assert: inst1 store.

	self assert: inst2 ordered _collectionEntries last entryID equals: nextID.
	self assert: inst1 ordered _collectionEntries last entryID equals: nextID + 1.

	self assert: record2 nextID equals: nextID + 1.
	self assert: record1 nextID equals: nextID + 2
]

{ #category : #'unit tests' }
SSWReStoreUpdateClashTest >> test12RollforwardNextIDAllocations [

	"Check originally-allocated IDs are preserved following detect-fail-rollforward"

	| inst1 inst2 new2 id |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	new2 := Test new name: 'new2'.

	self assert: (reStore evaluateAsTransaction: [inst1 name: 'test3:1']).
	self deny: (reStore2 evaluateAsTransaction: [inst2 name: 'test3:2'. new2 storeIn: reStore2]).

	id := new2 _id id.
	reStore2 refreshAndRollforwardTransaction.
	self assert: (reStore2 commitTransaction).

	self assert: new2 _id equals: id
]
