"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreDataIDTest,
	#superclass : #SSWReStoreIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
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
	self should: [reStore connection exec: 'update re_store_test_with_id set nmbr = 7 where nmbr = 2'] raise: reStore dbErrorClass.
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
		exec: 'update re_store_test_with_id set other = 9 where nmbr = 2';
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

	self assert: (reStore evaluateAsTxn: [(reStore connection exec: 'update next_id set next_id = 99 where table_name like ''re_store_test_with_id''') numRows = 1]).

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

{ #category : #constants }
SSWReStoreDataIDTest >> testClass [

	^ReStoreTestWithID
]
