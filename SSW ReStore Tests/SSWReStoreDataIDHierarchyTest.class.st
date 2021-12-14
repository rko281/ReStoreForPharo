Class {
	#name : #SSWReStoreDataIDHierarchyTest,
	#superclass : #SSWReStoreDataIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #adding }
SSWReStoreDataIDHierarchyTest >> addClassesTo: aReStore [

	aReStore addClassWithSubclasses: ReStoreTestWithIDOnly
]

{ #category : #constants }
SSWReStoreDataIDHierarchyTest >> testClass [

	^ReStoreTestWithIDSubclass
]

{ #category : #tests }
SSWReStoreDataIDHierarchyTest >> testClassWithIDOnly [

	"Test a previous failure case where the table for a class containing only a data ID field was regarded as undefined"

	| inst |

	self assert: (reStore tableForClass: ReStoreTestWithIDOnly) notNil.

	(ReStoreTestWithIDOnly new nmbr: 987654321) storeIn: reStore.

	reStore simulateReconnect.

	inst := (ReStoreTestWithIDOnly storedInstancesIn: reStore) detect: [ :each | each nmbr = 987654321].
	self assert: inst notNil.
	self assert: inst class equals: ReStoreTestWithIDOnly.
	self assert: inst nmbr = 987654321.

	self assert: ((ReStoreTestWithIDOnly storedInstancesIn: reStore) detect: [ :each | each nmbr = 123456789] ifNone: [nil]) isNil
]
