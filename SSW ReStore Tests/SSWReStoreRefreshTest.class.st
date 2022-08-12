"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRefreshTest,
	#superclass : #SSWReStore2Test,
	#category : #'SSW ReStore Tests'
}

{ #category : #running }
SSWReStoreRefreshTest >> createTestData [

	self createStandardTestInstance.
	reStore simulateReconnect.
	self refreshDelay
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test01 [

	"check it works for objects"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	"Update in one session"
	self assert: (reStore evaluateAsTransaction: [inst1 number: 11]).

	self assert: (inst1 number = 11).
	self assert: (inst2 number = 123).
	self refreshDelay.

	inst2 refresh.

	self assert: (inst2 number = 11)
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test02 [

	"check refresh doesn't occur when not updated"

	| inst1 inst2 prevNumber |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (inst1 name = 'owner').
	self assert: (inst2 name = 'owner').

	prevNumber := inst1 number.

	"Update directly via SQL to avoid changing the version (so not really updated)"
	reStore evaluateAsTxn: [reStore executeSQL: 'update owner_test set name = ''changed'''. true].
	self refreshDelay.

	inst1 refresh.
	inst2 refresh.

	self usesVersioning 
	ifTrue: 
		["the VERSION_ field wasn't changed, so no change detected"
		self assert: (inst1 name = 'owner').
		self assert: (inst2 name = 'owner')]
	ifFalse: 
		["no VERSION_ field, so updated regardless"
		self assert: (inst1 name = 'changed').
		self assert: (inst2 name = 'changed')].

	"now really update"
	self assert: (reStore evaluateAsTransaction: [inst1 number: 22]).
	self refreshDelay.

	self usesVersioning ifTrue:
		[self assert: (inst1 name = 'owner').
		self assert: (inst2 name = 'owner')].
	self assert: (inst1 number = 22).
	self assert: (inst2 number = prevNumber).

	inst2 refresh.

	self assert: (inst2 number = 22).
	self assert: (inst2 name = 'changed').

]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test03 [

	"check changes are remembered in copyObject"

	| inst1 inst2 prevNumber |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	prevNumber := inst1 number.

	"Update in one session"
	self assert: (reStore evaluateAsTransaction: [inst1 number: 9876]).

	self assert: (inst1 number = 9876).
	self assert: (inst2 number = prevNumber).
	self refreshDelay.

	inst2 refresh.

	self assert: (inst2 number = 9876).
	self deny: inst2 hasChanged
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test04 [

	"check it works with known objects"

	| inst1 num inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	"Update in one session"
	num := Time millisecondClockValue \\ 10000.

	self assert: (reStore evaluateAsTransaction: [inst1 number: num]).
	self assert: (inst1 number = num).

	self refreshDelay.
	(reStore2 cachedInstancesOf: OwnerTest) refreshAll.
	self assert: (inst2 number = num)
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test20 [

	"owned collections - add"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (inst1 ownedOrdered size = 2).
	self assert: (inst2 ownedOrdered size = 2).

	"update - add"
	self assert: (reStore evaluateAsTransaction: [inst1 ownedOrdered add: (OwnedTest new name: 'added')]).
	self refreshDelay.

	self assert: (inst1 ownedOrdered size = 3).
	self assert: (inst2 ownedOrdered size = 2).

	inst2 ownedOrdered refresh.

	self assert: (inst2 ownedOrdered size = 3).
	self assert: ((inst2 ownedOrdered collect: [ :e | e name]) asSortedCollection asArray = #('added' 'owned1' 'owned2'))


]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test21 [

	"owned collections - remove"

	| inst1 inst2 prevSize prevColl |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	prevSize := inst1 ownedOrdered size.
	prevColl := (inst1 ownedOrdered collect: [ :e | e name]) asSortedCollection.
	inst2 ownedOrdered size. "unproxy"

	"update - remove"
	self assert: (reStore evaluateAsTransaction: [inst1 ownedOrdered remove: (inst1 ownedOrdered detect: [ :e | e name = 'owned1'])]).
	self refreshDelay.

	self assert: (inst1 ownedOrdered size = (prevSize - 1)).
	self assert: (inst2 ownedOrdered size = prevSize).

	inst2 ownedOrdered refresh.

	self assert: (inst2 ownedOrdered size = (prevSize - 1)).
	self assert: ((inst2 ownedOrdered collect: [ :e | e name]) asSortedCollection asArray = (prevColl remove: 'owned1'; yourself) asArray)
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test23 [

	"owned collections - change"

	| inst1 inst2 prevSize prevColl |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	prevSize := inst1 ownedOrdered size.
	prevColl := (inst1 ownedOrdered collect: [ :e | e name]) asSortedCollection.
	inst2 ownedOrdered size. "unproxy"

	"update - remove and add"
	self assert: (reStore evaluateAsTransaction: [inst1 ownedOrdered remove: (inst1 ownedOrdered detect: [ :e | e name = 'owned2']); add: (OwnedTest new name: 'xyz')]).
	self refreshDelay.

	self assert: (inst1 ownedOrdered size = prevSize).
	self assert: (inst2 ownedOrdered size = prevSize).

	inst2 ownedOrdered refresh.

	self assert: (inst2 ownedOrdered size = prevSize).
	self assert: (inst2 ownedOrdered collect: [ :e | e name]) asSortedCollection asArray equals: (prevColl remove: 'owned2'; add: 'xyz'; yourself) asArray
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test24 [

	"owned collections - refresh with contents - change"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (inst1 ownedOrdered size = 2).
	self assert: (inst2 ownedOrdered size = 2).

	"update - change"
	self assert: (reStore evaluateAsTransaction: [inst1 ownedOrdered first name: 'test24']).
	self refreshDelay.

	self assert: (inst1 ownedOrdered first name = 'test24').
	self deny: (inst2 ownedOrdered anySatisfy: [ :e | e name = 'test24']).

	inst2 ownedOrdered refresh.

	self assert: (inst2 ownedOrdered size = 2).
	self assert: (inst2 ownedOrdered anySatisfy: [ :e | e name = 'test24']).

]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test25 [

	"owned collections - refresh with contents - change & add"

	| inst1 inst2 size1 size2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	size1 := inst1 ownedOrdered size.
	size2 := inst2 ownedOrdered size.

	"update - change + add"
	self assert: (reStore evaluateAsTransaction: [inst1 ownedOrdered first name: 'test25'. inst1 ownedOrdered add: (OwnedTest new name: 'test25add')]).
	self refreshDelay.

	size1 := size1 + 1.

	self assert: (inst1 ownedOrdered first name = 'test25').
	self assert: (inst1 ownedOrdered size = size1).
	self deny: (inst2 ownedOrdered anySatisfy: [ :e | e name = 'test25']).
	self assert: (inst2 ownedOrdered size = size2).

	inst2 ownedOrdered refresh.

	self assert: (inst2 ownedOrdered size = size1).
	self assert: (inst2 ownedOrdered first name = 'test25')
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test26 [

	"owned collections - refresh with contents - change & add - ensure changes make it to copy collection"

	| inst1 inst2 size1 size2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	size1 := inst1 ownedOrdered size.
	size2 := inst2 ownedOrdered size.

	"update - change + add"
	self assert: (reStore evaluateAsTransaction: [inst1 ownedOrdered first name: 'test26'. inst1 ownedOrdered add: (OwnedTest new name: 'test26add')]).
	self refreshDelay.

	size1 := size1 + 1.

	self assert: (inst1 ownedOrdered first name = 'test26').
	self assert: (inst1 ownedOrdered size = size1).
	self deny: (inst2 ownedOrdered anySatisfy: [ :e | e name = 'test26']).
	self assert: (inst2 ownedOrdered size = size2).

	inst2 refresh.

	self assert: (inst2 ownedOrdered size = size1).
	self assert: (inst2 ownedOrdered first name = 'test26').
	self deny: inst2 hasChanged
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test31 [

	"owned collections - refresh with contents - change auto-detect/touch of single object"

	| origName inst1 inst2 test1 test2 ver1 |

	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.
	test2 := inst2 ownedOrdered first.
	origName := test2 name.

	test1 := (Test storedInstancesIn: reStore) detect: [ :e | e name = origName] ifNone: [nil].
	self assert: (test1 notNil).
	self usesVersioning ifTrue: [ver1 := test1 _version].

	"update in session 2 - change"
	self assert: (reStore2 evaluateAsTransaction: [test2 name: 'ownedMod']).
	self refreshDelay.

	"Touch in session1 then read inst1's ordered collection - should not refresh test1 as it has been touched"
	test1 name.
	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	self assert: (inst1 ownedOrdered first == test1).
	self assert: (test1 name = origName).

	reStore rollbackTransaction.
	self usesVersioning ifTrue: [self assert: (test1 _version = ver1)].

	"Re-read; test1 should now be updated"
	inst1 ownedOrdered _forgetProxiedObject.
	self assert: (test1 name = origName).

	reStore rollbackTransaction.
	self assert: (inst1 ownedOrdered first == test1).	"<< will re-read ordered"
	self assert: (test1 name = 'ownedMod').
	self usesVersioning ifTrue: 
		[reStore rollbackTransaction.
		self assert: (test1 _version = (ver1 + 1))]
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test32 [

	"general collections - refresh with contents - change auto-detect/touch of single object"

	| inst1 inst2 test1 |

	test1 := (Test storedInstancesIn: reStore) detect: [ :e | e name = 'ordered1'] ifNone: [nil].
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (test1 notNil).
	self assert: (inst2 ordered first name = test1 name).

	"update - change"
	self assert: (reStore2 evaluateAsTransaction: [inst2 ordered first name: 'ordered1mod']).
	self refreshDelay.

	"Touch in session1 then read inst1's ordered collection - should not refresh test1 as it has been touched"
	test1 name.
	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	self assert: (inst1 ordered first == test1).
	self assert: (test1 name = 'ordered1').

	"Rollback and re-read; test1 should now be updated"
	reStore rollbackTransaction.
	inst1 ordered _forgetProxiedObject.
	self assert: (test1 name = 'ordered1').

	reStore rollbackTransaction.
	self assert: (inst1 ordered first == test1).	"<< will re-read ordered"
	self assert: (test1 name = 'ordered1mod')

]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test33 [

	"owned collections - refresh with contents - change auto-detect/touch of collection object"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (inst1 ownedOrdered size = 2).
	self assert: (inst2 ownedOrdered size = 2).

	"update - change"
	self assert: 
		(reStore evaluateAsTransaction: 
			[inst1 ownedOrdered first name: 'testA1'.
			inst1 ownedOrdered last name: 'testA2']).
	self refreshDelay.

	"Ensure everything is set up as we want"
	self assert: (inst1 ownedOrdered first name = 'testA1').
	self assert: (inst1 ownedOrdered last name = 'testA2').
	self deny: (inst2 ownedOrdered anySatisfy: [ :e | e name = 'testA1']).
	self deny: (inst2 ownedOrdered anySatisfy: [ :e | e name = 'testA2']).

	"Rollback then touch one"
	reStore2 rollbackTransaction.
	inst2 ownedOrdered last name.

	"Read them"
	self assert: ((OwnedTest storedInstancesIn: reStore2) satisfying: [ :each | each owner = inst2]) asOrderedCollection size equals: 2.

	"Although we read the latest versions, should not have refreshed the last one as it was touched"
	self assert: (inst2 ownedOrdered first name = 'testA1').
	self deny: (inst2 ownedOrdered last name = 'testA2').

	"Untouch and re-read"
	reStore2 rollbackTransaction.
	(Test storedInstancesIn: reStore2) asOrderedCollection.

	"Should now have picked up the change"
	self assert: (inst2 ownedOrdered first name = 'testA1').
	self assert: (inst2 ownedOrdered last name = 'testA2')
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test34 [

	"general collections - refresh with contents - change auto-detect/touch of collection object"

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (inst1 ordered size = 2).
	self assert: (inst2 ordered size = 2).

	"update - change"
	self assert: 
		(reStore evaluateAsTransaction: 
			[inst1 ordered first name: 'testB1'.
			inst1 ordered last name: 'testB2']).
	self refreshDelay.

	"Ensure everything is set up as we want"
	self assert: (inst1 ordered first name = 'testB1').
	self assert: (inst1 ordered last name = 'testB2').
	self deny: (inst2 ordered anySatisfy: [ :e | e name = 'testB1']).
	self deny: (inst2 ordered anySatisfy: [ :e | e name = 'testB2']).

	"Rollback then touch one"
	reStore2 rollbackTransaction.
	inst2 ordered last name.

	"Read them"
	(Test storedInstancesIn: reStore2) asOrderedCollection.

	"Although we read the latest versions, should not have refreshed the last one as it was touched"
	self assert: (inst2 ordered first name = 'testB1').
	self deny: (inst2 ordered last name = 'testB2').

	"Untouch and re-read"
	reStore2 rollbackTransaction.
	(Test storedInstancesIn: reStore2) asOrderedCollection.

	"Should now have picked up the change"
	self assert: (inst2 ordered first name = 'testB1').
	self assert: (inst2 ordered last name = 'testB2')
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test35 [

	"test only actual changed things are updated"

	| inst1 inst2 name1 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	self assert: (inst1 name = 'owner').
	self assert: (inst1 number = 123).
	name1 := inst1 name.

	self assert: (inst2 name = 'owner').
	self assert: (inst2 number = 123).

	"Rollback and refresh - shouldn't do anything as no change"
	reStore rollbackTransaction.
	(OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	self assert: (inst1 name = 'owner').
	self assert: (inst1 number = 123).
	self assert: (inst1 name == name1).
	self assert: (inst1 refreshCount = 0).

	"update - change in other session"
	self assert: (reStore2 evaluateAsTransaction: [inst2 number: 987]).
	self refreshDelay.

	"Rollback, touch and refresh - shouldn't do anything due to touch"
	reStore rollbackTransaction.
	inst1 name.
	(OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	self assert: (inst1 name = 'owner').
	self assert: (inst1 number = 123).
	self assert: (inst1 name == name1).

	"Rollback and refresh - should update, but only number"
	reStore rollbackTransaction.
	(OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	self assert: (inst1 name = 'owner').
	self assert: (inst1 number = 987).
	self assert: (inst1 name == name1).
	self assert: (inst1 refreshCount = 1)
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> test40QueryingShouldRefresh [

	"Check it doesn't update when toched/does when not touched"

	| insts realInsts |

	insts := (OwnerTest storedInstancesIn: reStore) satisfying: [ :e | e name = 'refreshTest40'].

	"Get rid of previous data then recreate"
	insts unstoreAll.

	reStore evaluateAsTransaction:
		[1 to: 10 do: [ :i | OwnerTest new name: 'refreshTest40'; number: i; storeIn: reStore]].

	reStore simulateReconnect.

	realInsts := insts asSortedCollection: [ :a :b | a number < b number].

	self assert:
		((realInsts collect: [ :each | each number]) asSortedCollection asArray = #(1 2 3 4 5 6 7 8 9 10)).

	"Update in the other session"
	((reStore2 instancesOf: OwnerTest) satisfying: [ :e | e name = 'refreshTest40']) modify: [ :e | e number: e number + 10].

	self refreshDelay.

	"We touched the insts in the first session earlier, so they'll initially ignore the change above"
	self assert:
		(((insts
			asOrderedCollection)
				collect: [ :each | each number]) asSortedCollection asArray = #(1 2 3 4 5 6 7 8 9 10)).

	"Rollback - they'll then refresh themselves when their row is brought in"
	reStore rollbackTransaction.

	"...but for fun, we'll touch a couple of them"
	realInsts first name.
	realInsts second name.

	self assert:
		(((insts
			asOrderedCollection)
				collect: [ :each | each number]) asSortedCollection asArray = #(1 2 13 14 15 16 17 18 19 20)).

	"And finally we'll refresh 'em all"
	reStore rollbackTransaction.

	self assert:
		(((insts
			asOrderedCollection)
				collect: [ :each | each number]) asSortedCollection asArray = #(11 12 13 14 15 16 17 18 19 20)).

]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> testGeneralCollectionRefreshQueryCount [

	"test one query is needed to refresh a general collection, even with a change"

	| inst1 inst2 queryCount |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	"ensure inst1 is touched"
	self deny: inst1 ordered first name equals: 'testB1'.

	"update - change"
	inst2 ordered first name: 'testB1'.
	self assert: inst2 store.

	self refreshDelay.

	queryCount := self countQueriesDuring: [inst1 ordered refresh]. 

	self assert:  queryCount equals: 1.
	self assert: inst1 ordered first name equals: 'testB1'
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> testOwnedCollectionRefreshQueryCount [

	"test one query is needed to refresh a owned collection, even with a change"

	| inst1 inst2 queryCount |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	"ensure inst1 is touched"
	self deny: inst1 ownedOrdered first name equals: 'testB1'.

	"update - change"
	inst2 ownedOrdered first name: 'testB1'.
	self assert: inst2 store.

	self refreshDelay.
	queryCount := self countQueriesDuring: [inst1 ownedOrdered refresh]. 

	self assert: queryCount equals: 1.
	self assert: inst1 ownedOrdered first name equals: 'testB1'
]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> testRefreshOfCopyObject [

	| inst1 inst2 |

	inst1 := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	inst2 := (OwnerTest storedInstancesIn: reStore2) asOrderedCollection first.

	"Update in one session"
	self assert: (reStore evaluateAsTransaction: [inst1 number: 11]).

	self assert: inst1 number equals: 11.
	self assert: inst2 number equals: 123.
	self refreshDelay.

	inst2 refresh.

	self assert: inst2 isDBProxy.
	self assert: inst2 _proxiedObject number equals: 11.
	self assert: inst2 _copyObject number equals: 11.

]

{ #category : #'unit tests' }
SSWReStoreRefreshTest >> testRefreshWithOnRollback [

	"Test previously-failing case where refreshing an object with an onRollback implementation which references an also-refreshed linked persistent object caused incorrect proxy swapping"

	"Add an appropriate implementation of onRollback to both classes involved in the test since ordering of objects in transaction varies"
	self 
		addMethod: OwnedTest>>#testOnRollback withSelector: #onRollback toClass: OwnedTest;
		addMethod: OwnerTest>>#testOnRollback withSelector: #onRollback toClass: OwnerTest.

	[| owner owned |

	owner := (OwnerTest storedInstancesIn: reStore) asOrderedCollection first.
	owner owned: (OwnedTest new name: 'owned'; owner: owner; yourself); store.

	self assert: owner isDBProxy.	
	owned := owner owned.
	self assert: owned isDBProxy.
	owned name.

	owner refresh.

	self assert: owner isDBProxy.	
	self assert: owned isDBProxy.

	] ensure: 
		[self 
			removeSelector: #onRollback fromClass: OwnedTest;
			removeSelector: #onRollback fromClass: OwnerTest]
]

{ #category : #running }
SSWReStoreRefreshTest >> usesVersioning [

	^true
]
