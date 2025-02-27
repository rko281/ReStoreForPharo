"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreDefaultWriteTest',
	#superclass : 'SSWReStoreDefaultTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'Running' }
SSWReStoreDefaultWriteTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.

	aReStore 
		addClass: OwnerTest;
		addClass: OwnedTest
]

{ #category : 'Running' }
SSWReStoreDefaultWriteTest >> createTestData [

	super createTestData.

	reStore evaluateAsTransaction:
		[((SimplePerson storedInstancesIn: reStore) detect: [ :each | each fullName = 'John Smith']) address: (SimpleAddress new postcode: 'J1 1JJ')].

	OwnerTest new
		name: 'owner';
		ownedOrdered: 
			(OrderedCollection
				with: (OwnedTest new name: 'owned1')
				with: (OwnedTest new name: 'owned2'));
		store
]

{ #category : 'Running' }
SSWReStoreDefaultWriteTest >> setUp [

	super setUp.

	reStore evaluateAsTransaction:
		[((SimplePerson storedInstancesIn: reStore) detect: [ :each | each fullName = 'John Smith']) address: (SimpleAddress new postcode: 'J1 1JJ')].

	OwnerTest new
		name: 'owner';
		ownedOrdered: 
			(OrderedCollection
				with: (OwnedTest new name: 'owned1')
				with: (OwnedTest new name: 'owned2'));
		store
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testCommitFailure [

	"Test the handling of commit failures"

	| zoe1 zoe2 oldAge newAge1 newAge2 |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	zoe2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = zoe1 fullName].

	oldAge := zoe1 age.
	newAge1 := oldAge + 1.
	newAge2 := oldAge + 2.

	zoe1 age: newAge1.
	reStore2 evaluateAsTransaction: [zoe2 age: newAge2].

	self refreshDelay.

	"Commit should fail due to update clash"
	self deny: zoe1 store.

	"Rollback"
	zoe1 rollback.
	self assert: zoe1 age = oldAge.

	"Refresh"
	zoe1 refresh.
	self assert: zoe1 age = newAge2.

	"Retry"
	zoe1 age: newAge1.
	self assert: zoe1 store.

	"Double check"
	zoe2 refresh.
	self assert: zoe2 age = newAge1
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRefreshExistingObject [

	"Test the use of the refresh message to refresh an existing object"

	| zoe1 newAge zoe2 |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].

	zoe2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = zoe1 fullName].
	newAge := zoe1 age + 1.
	reStore2 evaluateAsTransaction: [zoe2 age: newAge].

	self assert: zoe1 age = (newAge - 1).

	self refreshDelay.
	zoe1 refresh.

	self assert: zoe1 age = newAge
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRefreshExistingObjects [

	"Test the use of the refresh message to refresh a collection of existing objects"

	| zoe1 newAge zoe2 john1 john2 |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].

	zoe2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = zoe1 fullName].
	newAge := zoe1 age + 1.

	john2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = john1 fullName].
	reStore2 evaluateAsTransaction: 
		[zoe2 age: newAge.
		john2 address postcode: 'JS1 1JS'].

	self assert: zoe1 age = (newAge - 1).
	self assert: (john1 address postcode ~= 'JS1 1JS').

	self refreshDelay.
	(Array with: zoe1 with: john1) refreshAll.

	self assert: zoe1 age = newAge.
	self assert: (john2 address postcode = 'JS1 1JS')
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRefreshExistingRelatedObject [

	"Test the use of the refresh message to refresh an existing related object"

	| john1 john2 |

	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].

	john2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = john1 fullName].
	reStore2 evaluateAsTransaction: [john2 address postcode: 'JS1 1JS'].

	self assert: (john1 address postcode ~= 'JS1 1JS').

	self refreshDelay.
	john1 refresh.

	self assert: (john2 address postcode = 'JS1 1JS').
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRefreshPersistentCollection [

	"Test the behaviour of the refresh message when sent to a persistent collection (as opposed to a non-persistent collection of persistent objects)"

	| owner1 owner2 |

	owner1 := OwnerTest storedInstances first.
	owner2 := (OwnerTest storedInstancesIn: reStore2) first.

	reStore2 evaluateAsTransaction: 
		[owner2 ownedOrdered first name: 'changed'.
		owner2 ownedOrdered addLast: (OwnedTest new name: 'added')].

	self refreshDelay.
	owner1 refresh.

	self assert: owner1 ownedOrdered size = 3.
	self assert: owner1 ownedOrdered first name = 'changed'.
	self assert: owner1 ownedOrdered last name = 'added'
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRollbackExistingObject [

	"Test the use of the rollback message with a single object"

	| zoe1 newAge |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	newAge := zoe1 age + 1.
	zoe1 age: newAge.
	zoe1 rollback.

	self assert: (zoe1 age = (newAge - 1))
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRollbackExistingObjects [

	"Test the use of the rollback message with a collection of objects"

	| zoe1 newAge john1 oldPostcode |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	newAge := zoe1 age + 1.
	zoe1 age: newAge.

	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	oldPostcode := john1 address postcode.
	john1 address postcode: 'JS1 1JS'.

	(Array with: zoe1 with: john1) rollbackAll.

	self assert: (zoe1 age = (newAge - 1)).
	self assert: (john1 address postcode ~= 'JS1 1JS').
	self assert: (john1 address postcode = oldPostcode)

]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRollbackExistingRelatedObject [

	"Test the use of the rollback message with a single related object"

	| john1 oldPostcode |

	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	oldPostcode := john1 address postcode.
	john1 address postcode: 'JS1 1JS'.
	john1 rollback.

	self assert: (john1 address postcode ~= 'JS1 1JS').
	self assert: (john1 address postcode = oldPostcode)
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testRollbackPersistentCollection [

	"Test the behavior of the rollback message when sent to a persistent collection (as opposed to a non-persistent collection of persistent objects)"

	| owner1 oldName|

	owner1 := OwnerTest storedInstances first.

	oldName := owner1 ownedOrdered first name.
	owner1 ownedOrdered first name: 'changed'.
	owner1 ownedOrdered addLast: (OwnedTest new name: 'added').

	owner1 rollback.

	self assert: owner1 ownedOrdered size = 2.
	self assert: owner1 ownedOrdered first name = oldName
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testStoreExistingObject [

	"Test the use of the store message to update an existing object"

	| zoe1 newAge zoe2 |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	newAge := zoe1 age + 1.
	zoe1 age: newAge.
	zoe1 store.

	zoe2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = zoe1 fullName].
	self assert: zoe2 age = newAge
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testStoreExistingRelatedObject [

	"Test the use of the store message to update an existing related object"

	| john1 john2 |

	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	john1 address postcode: 'JS1 1JS'.
	john1 store.

	john2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = john1 fullName].
	self assert: (john2 address postcode = 'JS1 1JS').
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testStoreMixedObjects [

	"Test the use of the storeAll message to save a collection of new and existing objects"

	| zoe1 newAge john1 alan zoe2 john2 |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	newAge := zoe1 age + 1.
	zoe1 age: newAge.

	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	john1 address postcode: 'JS1 1JS'.

	alan := self newAlan.

	(Array with: zoe1 with: john1 with: alan) storeAll.

	zoe2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = zoe1 fullName].
	self assert: zoe2 age = newAge.

	john2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = john1 fullName].
	self assert: (john2 address postcode = 'JS1 1JS').

	self assert: ((SimplePerson storedInstancesIn: reStore2) select: [ :each | each fullName = alan fullName]) notNil
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testStoreNewObject [

	"Test the use of the store message to create a new object"

	| alan alan2 |

	alan := self newAlan.
	alan store. 

	self assert: alan _id notNil.
	self assert: alan address _id notNil. "<- related object"

	alan2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = alan fullName] ifNone: [nil].
	self assert: alan2 notNil.
	self assert: (alan2 address postcode = alan address postcode)
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testStoreNewRelatedObject [

	"Test the use of the store message to update an existing related object"

	| zoe1 zoe2 |

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	zoe1 address: (SimpleAddress new postcode: 'Z1 1ZZ').
	zoe1 store.

	self assert: zoe1 address _id notNil.

	zoe2 := (SimplePerson storedInstancesIn: reStore2) detect: [ :each | each fullName = zoe1 fullName].
	self assert: (zoe2 address postcode = 'Z1 1ZZ').
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testStorePersistentCollection [

	"Test the behaviour of the store message when sent to a persistent collection (as opposed to a non-persistent collection of persistent objects)"

	| owner1 owner2 |

	owner1 := OwnerTest storedInstances first.

	owner1 ownedOrdered first name: 'changed'.
	owner1 ownedOrdered addLast: (OwnedTest new name: 'added').

	owner1 ownedOrdered store.

	self refreshDelay.
	owner2 := (OwnerTest storedInstancesIn: reStore2) first.

	self assert: owner2 ownedOrdered size = 3.
	self assert: owner2 ownedOrdered first name = 'changed'.
	self assert: owner2 ownedOrdered last name = 'added'
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testUnstoreAllInstancesCollection [

	"Test the use of the unstore message with an entire InstancesCollection of objects"

	self deny: SimplePerson storedInstances isEmpty.

	SimplePerson storedInstances unstoreAll.

	self assert: SimplePerson storedInstances isEmpty
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testUnstoreExistingObject [

	"Test the use of the unstore message"

	| personCount addressCount john1 postcode |

	personCount := SimplePerson storedInstances size.
	addressCount := SimpleAddress storedInstances size.

	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	postcode := john1 address postcode.

	john1 unstore.

	"Ensure we've deleted the person and the address objects"
	self assert: SimplePerson storedInstances size = (personCount - 1).
	self assert: SimpleAddress storedInstances size = (addressCount - 1).
	self assert: (SimplePerson storedInstances select: [ :each | each fullName = 'John Smith']) isEmpty.
	self assert: (SimpleAddress storedInstances select: [ :each | each postcode = postcode]) isEmpty
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testUnstoreExistingObjects [

	"Test the use of the unstore message with a collection of objects"

	| personCount addressCount zoe1 john1 postcode |

	personCount := SimplePerson storedInstances size.
	addressCount := SimpleAddress storedInstances size.

	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	postcode := john1 address postcode.

	(Array with: zoe1 with: john1) unstoreAll.

	"Ensure we've deleted the person and the address objects"
	self assert: SimplePerson storedInstances size = (personCount - 2).
	self assert: SimpleAddress storedInstances size = (addressCount - 1). "Only John had an address"

	self assert: (SimplePerson storedInstances select: [ :each | each fullName = 'Zoe Brown']) isEmpty.
	self assert: (SimplePerson storedInstances select: [ :each | each fullName = 'John Smith']) isEmpty.
	self assert: (SimpleAddress storedInstances select: [ :each | each postcode = postcode]) isEmpty.
]

{ #category : 'unit tests' }
SSWReStoreDefaultWriteTest >> testUnstoreInstancesCollection [

	"Test the use of the unstore message with an InstancesCollection of objects.
	Note this does not follow dependency rules"

	| personCount addressCount instances |

	personCount := SimplePerson storedInstances size.
	addressCount := SimpleAddress storedInstances size.

	instances := SimplePerson storedInstances satisfying: [ :each | (each fullName = 'Zoe Brown') | (each fullName = 'John Smith')].
	self assert: instances class = SSWDBInstancesCollection.

	instances unstoreAll.

	self assert: SimplePerson storedInstances size = (personCount - 2).
	self assert: SimpleAddress storedInstances size = addressCount. "This unstore method ignores dependency"

	self assert: (SimplePerson storedInstances select: [ :each | each fullName = 'Zoe Brown']) isEmpty.
	self assert: (SimplePerson storedInstances select: [ :each | each fullName = 'John Smith']) isEmpty
]
