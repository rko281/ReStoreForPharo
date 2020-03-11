"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreRemoteTest,
	#superclass : #SSWReStoreTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #running }
SSWReStoreRemoteTest >> createTestData [

	self createStandardTestInstance.
	reStore simulateReconnect
]

{ #category : #'unit tests' }
SSWReStoreRemoteTest >> test1OwnedRemote [

	| inst |

	inst := (OwnerTest storedInstancesIn: reStore) first.

	self assert: (inst ownedOrdered remote size = 2).
	self assert: (inst ownedOrdered remote asOrderedCollection anySatisfy: [ :each | each name = 'owned1']).
	self assert: (inst ownedOrdered orRemote size = 2).
	self assert: (inst ownedOrdered orRemote asOrderedCollection anySatisfy: [ :each | each name = 'owned1']).
	self assert: (inst ownedOrdered isDBProxy).

	reStore beginTransaction.
	inst ownedOrdered add: (OwnedTest new name: 'owned3').
	self deny: (inst ownedOrdered isDBProxy).

	self assert: (inst ownedOrdered remote size = 2).
	self assert: (inst ownedOrdered remote asOrderedCollection anySatisfy: [ :each | each name = 'owned1']).
	self assert: (inst ownedOrdered orRemote size = 3).
	self assert: (inst ownedOrdered orRemote asOrderedCollection last name = 'owned3').

	reStore commitTransaction.	
	self assert: (inst ownedOrdered remote size = 3).
	self assert: (inst ownedOrdered remote asOrderedCollection last name = 'owned3').


]

{ #category : #'unit tests' }
SSWReStoreRemoteTest >> test2GeneralRemote [

	| inst |

	inst := (OwnerTest storedInstancesIn: reStore) first.

	self assert: (inst ordered remote size = 2).
	self assert: (inst ordered remote asOrderedCollection first name = 'ordered1').
	self assert: (inst ordered orRemote size = 2).
	self assert: (inst ordered orRemote asOrderedCollection first name = 'ordered1').
	self assert: (inst ordered isDBProxy).

	reStore beginTransaction.
	inst ordered add: (Test new name: 'ordered3').
	self deny: (inst ordered isDBProxy).

	self assert: (inst ordered remote size = 2).
	self assert: (inst ordered remote asOrderedCollection first name = 'ordered1').
	self assert: (inst ordered orRemote size = 3).
	self assert: (inst ordered orRemote asOrderedCollection last name = 'ordered3').

	reStore commitTransaction.
	self assert: (inst ordered remote size = 3).
	self assert: (inst ordered remote asOrderedCollection last name = 'ordered3')
]
