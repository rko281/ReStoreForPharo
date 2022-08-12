"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreCommitTests,
	#superclass : #SSWReStorePersonTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #Running }
SSWReStoreCommitTests >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore
		addClass: OwnerTest;
		addClass: Test
]

{ #category : #public }
SSWReStoreCommitTests >> test01SelfReference [

	| obj |

	obj := SimplePerson new firstName: 'Dave'.
	obj friend: obj.
	reStore evaluateAsTransaction: [obj storeIn: reStore].

	reStore simulateReconnect.

	obj := (SimplePerson storedInstancesIn: reStore) first.
	self assert: (obj friend == obj)

	
]

{ #category : #public }
SSWReStoreCommitTests >> test02MultiCommitSameObject [

	| obj success people|

	obj := SimplePerson new firstName: 'Dave'.
	reStore evaluateAsTransaction: [obj storeIn: reStore].

	reStore simulateReconnect.

	obj := (SimplePerson storedInstancesIn: reStore) first.
	obj firstName: 'David'.

	self shouldnt: [success := ((Array new: 20) atAllPut: obj; yourself) storeAll] raise: Error.
	self assert: success.

	reStore simulateReconnect.
	people := SimplePerson storedInstancesIn: reStore.
	self assert: (people size = 1).
	obj := people first.
	self assert: (obj firstName = 'David')
]

{ #category : #public }
SSWReStoreCommitTests >> test03MultiStoreSameObject [

	| obj success people |

	obj := SimplePerson new firstName: 'Dave'.
	self shouldnt: [success := ((Array with: obj with: obj with: obj with: obj) storeAllIn: reStore)] raise: Error.
	self assert: success.

	reStore simulateReconnect.
	people := SimplePerson storedInstancesIn: reStore.
	self assert: (people size = 1).
	obj := people first.
	self assert: (obj firstName = 'Dave')
]

{ #category : #public }
SSWReStoreCommitTests >> test04MultiStoreSameObjectViaRelationships [

	| obj1 obj2 tst success ownerTests tests |

	obj1 := OwnerTest template name: 'owner1'.
	obj2 := OwnerTest template name: 'owner2'.
	tst := Test new name: 'test'.

	"single2 and single3 are dependents"
	obj1 
		single2: tst;
		single3: tst.
	obj2 
		single2: tst;
		single3: tst.

	self shouldnt: [success := ((Array with: obj1 with: obj2 with: tst) storeAllIn: reStore)] raise: Error.
	self assert: success.

	reStore simulateReconnect.
	ownerTests := (OwnerTest storedInstancesIn: reStore) sortBlock: [ :a :b | a name <= b name].
	tests := (Test storedInstancesIn: reStore) sortBlock: [ :a :b | a name <= b name].
	self assert: (ownerTests size = 2).
	self assert: (tests size = 1).
	obj1 := ownerTests first.
	obj2 := ownerTests last.
	self assert: (tests first == obj1 single2).
	self assert: (obj1 single2 == obj1 single3).
	self assert: (tests first == obj2 single2).
	self assert: (obj2 single2 == obj2 single3)
]
