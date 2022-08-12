"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreTransactionlessUpdateClashTest,
	#superclass : #SSWReStoreUpdateClashTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #'unit tests' }
SSWReStoreTransactionlessUpdateClashTest >> test01DetectAndMerge [

	"Check detect and pass (independent changes)"

	| inst1 inst2 origName |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	origName := inst1 name.

	inst1 number: 11.
	inst2 name: 'test1:2'.
	self assert: inst1 store.
	self assert: inst2 store.

	self deny: reStore hasTransaction.
	self deny: reStore2 hasTransaction.

	self assert: (inst1 isDBProxy).
	self assert: (inst1 _proxiedObject number = 11).		"Change persisted"
	self assert: (inst1 _copyObject number = 11).		"...and copied"
	self assert: (inst1 _proxiedObject name = origName).	"Change not picked up till refresh"
	self assert: (inst1 _proxiedObject name = origName).	"Changed not picked up till refresh"

	self assert: (inst2 isDBProxy).
	self assert: (inst2 _proxiedObject number = 11).		"Change in session1 picked up and merged"
	self assert: (inst2 _copyObject number = 11).		"...and copied"
	self assert: (inst2 _proxiedObject name = 'test1:2').	"Change persisted"
	self assert: (inst2 _proxiedObject name = 'test1:2').	"...and copied"

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
SSWReStoreTransactionlessUpdateClashTest >> test02DetectNoMerge [

	"Check detect and fail (independent changes but merge prevented)"
	
	| inst1 inst2 oldNumber |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	oldNumber := inst1 number.

	"OwnerTest blocks updates on instances with this name..."
	inst1 name: 'blockMerge'.
	self assert: inst1 store.
	"...so the following will fail"
	inst2 number: 99.
	self deny: inst2 store. 

	inst2 refresh.
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
SSWReStoreTransactionlessUpdateClashTest >> test03DetectFailRollback [

	"Check detect-fail-rollback"

	| inst1 inst2 oldSingle |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	oldSingle := inst2 single1 name.

	inst1 name: 'test2:1'.
	inst2 name: 'test2:2'. 
	inst2 single1 name: 'single2:2'.

	self assert: inst1 store.
	self deny: (Array with: inst2 with: inst2 single1) storeAll. 

	self deny: reStore hasTransaction.
	self deny: reStore2 hasTransaction.

	(Array with: inst2 with: inst2 single1) refreshAll. 
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
SSWReStoreTransactionlessUpdateClashTest >> test04DetectFailRollforward [

	"Check detect-fail-rollforward"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	inst1 name: 'test3:1'.
	inst2 name: 'test3:2'. 
	inst2 single1 name: 'single3:2'.

	self assert: inst1 store.
	self deny: ([(Array with: inst2 with: inst2 single1) storeAll] on: StoreFailure do: [ :exc | exc return: false]).

	self deny: reStore hasTransaction.
	self assert: reStore2 hasTransaction.

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
SSWReStoreTransactionlessUpdateClashTest >> test05DetectFailAndHandle [

	"Check detect-fail-handle-pass"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	inst1 single1 name.
	inst2 single1 name.

	inst1 single1 name: 'single4:1'.
	inst2 name: 'test4:2'. 
	inst2 single1 name: 'single4:2'.

	self assert: inst1 single1 store.
	self assert: (Array with: inst2 with: inst2 single1) storeAll. 

	self deny: reStore hasTransaction.
	self deny: reStore2 hasTransaction.

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
SSWReStoreTransactionlessUpdateClashTest >> test06DetectFailNoHandle [

	"Check detect-fail-handle-fail"

	| inst1 inst2 oldName oldSingle |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	inst1 single1 name.
	oldName := inst2 name.
	oldSingle := inst2 single1 name.

	inst1 name: 'test5:1'. 
	inst1 single1 name: 'BLOCK5:1'.
	inst2 name: 'test5:2'. 
	inst2 single1 name: 'single5:2'.

	self assert: (Array with: inst1 with: inst1 single1) storeAll.
	self deny: (Array with: inst2 with: inst2 single1) storeAll.

	self deny: reStore hasTransaction.
	self deny: reStore2 hasTransaction.

	(Array with: inst2 with: inst2 single1) rollbackAll.

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
