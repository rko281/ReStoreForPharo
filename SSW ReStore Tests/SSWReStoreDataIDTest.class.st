"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreDataIDTest,
	#superclass : #SSWReStoreIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #running }
SSWReStoreDataIDTest >> createTestData [
	
	"Write data with assigned id"

	| obj2 obj7 obj9 |

	obj2 := self testClass name: 'dave' nmbr: 2.
	obj7 := self testClass name: 'john' nmbr: 7.
	obj9 := self testClass name: 'jim' nmbr: 9.

	obj2 other: obj7.

	(Array with: obj2 with: obj7 with: obj9) storeAllIn: reStore.
	
	reStore simulateReconnect
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test1VerifySetUp [

	"Verify setUp data is correct"

	| obj2 |

	obj2 := self testInstances detect: [:each | each name = 'dave'].

	self assert: obj2 nmbr equals: 2.
	self assert: obj2 other nmbr equals: 7.
	self assert: obj2 other name equals: 'john'
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test2DuplicateCheck [

	"Check can't update to a duplicate assigned ID"

	reStore connection beginRWTxn.

	"Depending on database this query will either generate an error or return zero rows affected"
	self assert: ([(reStore connection exec: 'update re_store_test_with_id set nmbr = 7 where nmbr = 2') rowsAffected] on: reStore dbErrorClass do: [ :exc | exc return: 0]) equals: 0.
	reStore connection rollbackTxn
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test3Update [

	"Check update"

	| obj2 |

	obj2 := self testInstances detect: [:each | each name = 'dave'].

	self assert: obj2 nmbr equals: 2.
	self assert: obj2 other nmbr equals: 7.
	self assert: obj2 other name equals: 'john'.

	reStore connection
		beginRWTxn;
		exec: 'update <1s> set other = 9 where nmbr = 2' << (reStore tableForClass: self testClass) name;
		commitTxn.

	reStore simulateReconnect.
	
	obj2 := self testInstances detect: [:each | each name = 'dave'].

	self assert: obj2 nmbr equals: 2.
	self assert: obj2 other nmbr equals: 9.
	self assert: obj2 other name equals: 'jim'
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test4Query [

	| matches |

	matches := self testInstances select: [ :e | e nmbr = 2].
	self assert: matches size equals: 1.
	self assert: matches first name equals: 'dave'.

	matches := self testInstances select: [ :e | e nmbr = 99].
	self assert: matches isEmpty
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test5QueryByExample [

	| template matches |

	template := self testClass new nmbr: 7.

	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first name equals: 'john'.

	template name: 'john'.
	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first name equals: 'john'.

	template name: 'xyz'.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty.

	template := self testClass new nmbr: 100.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty.

	template name: 'john'.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test6VerifyIDInCopy [

	"Test issue where data ID value was not set in copyObject"

	| obj2 |

	obj2 := self testInstances detect: [:each | each name = 'dave'].

	self assert: obj2 _dbProxy _copyObject nmbr equals: 2.
	self assert: obj2 other _dbProxy _copyObject nmbr equals: 7
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test7VerifyAssignedID [

	"Test an automatically-assigned ID makes it into a new instance when stored"

	| newObj recoveredObj |

	self assert: (reStore evaluateAsTxn: [(reStore connection exec: ('update next_id set next_id = 99 where table_name like <1p>') << (reStore tableForClass: self testClass) name) numRows = 1]).

	"Verify ID is fully assigned to new instances"
	newObj := self testClass new name: 'assign_test_1'.
	self assert: newObj nmbr isNil.

	self assert: (newObj storeIn: reStore).
	self assert: newObj nmbr equals: 99.
	self assert: newObj _dbProxy _copyObject nmbr equals: 99.

	newObj := self testClass new name: 'assign_test_2'.
	self assert: newObj nmbr isNil.
	self assert: (newObj storeIn: reStore).
	self assert: newObj nmbr equals: 100.
	self assert: newObj _dbProxy _copyObject nmbr equals: 100.

	reStore simulateReconnect.

	"Verify ID persisted in DB"
	recoveredObj := self testInstances detect: [ :e | e name = 'assign_test_1'].
	self assert: recoveredObj nmbr equals: 99.

	recoveredObj := self testInstances detect: [ :e | e name = 'assign_test_2'].
	self assert: recoveredObj nmbr equals: 100.

	"Check NEXT_ID table was updated correctly"
	newObj := self testClass new name: 'assign_test_3'.
	self assert: newObj nmbr isNil.
	self assert: (newObj storeIn: reStore).
	self assert: newObj nmbr equals: 101
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test8CheckForKnownDuplicateID [

	"Check for an attempt to persist an object with the already-allocated ID of an object known to ReStore (i.e. in the image) - this is most likely to arise from a copy.
	This should fail with a sensible message prior to DB insertion (i.e. failure shouldn't be from a unique key violation in the database)"

	| obj2 id |

	obj2 := self testInstances detect: [:each | each name = 'dave'].
	id := (reStore tableForClass: self testClass) idField accessor valueIn: obj2.
	
	self assert: ([obj2 copy storeIn: reStore. false] on: Error do: [ :exc | self assert: exc description equals: ('<1s>attempt to store object of class <2d> with duplicate ID <3p>' << {self errorPrefix. obj2 class. id}). exc return: true])
]

{ #category : #'unit tests' }
SSWReStoreDataIDTest >> test9CheckForUnknownDuplicateID [

	"Check for an attempt to persist an object with the already-allocated ID of an object not known to ReStore (i.e not in the image).
	This should fail with a unique key violation in the database"

	| obj2 |

	obj2 := self testClass name: 'dave' nmbr: 2.
	
	self should: [obj2 copy storeIn: reStore. false] raise: Error
]

{ #category : #constants }
SSWReStoreDataIDTest >> testClass [

	^ReStoreTestWithID
]
