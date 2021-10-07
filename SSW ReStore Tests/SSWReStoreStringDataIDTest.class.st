Class {
	#name : #SSWReStoreStringDataIDTest,
	#superclass : #SSWReStoreDataIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #tests }
SSWReStoreStringDataIDTest >> test2DuplicateCheck [

	"Check can't update to a duplicate assigned ID"

	reStore connection beginRWTxn.
	self should: [reStore connection exec: 'update re_store_test_with_string_id set name = ''john'' where name = ''dave'''] raise: reStore dbErrorClass.
	reStore connection rollbackTxn
]

{ #category : #tests }
SSWReStoreStringDataIDTest >> test3Update [

	"Check update"

	| obj2 |

	obj2 := self testInstances detect: [:each | each name = 'dave'].

	self assert: obj2 nmbr equals: 2.
	self assert: obj2 other nmbr equals: 7.
	self assert: obj2 other name equals: 'john'.

	reStore connection
		beginRWTxn;
		exec: 'update re_store_test_with_string_id set other = ''jim'' where nmbr = 2';
		commitTxn.

	reStore simulateReconnect.
	
	obj2 := self testInstances detect: [:each | each name = 'dave'].

	self assert: obj2 nmbr equals: 2.
	self assert: obj2 other nmbr equals: 9.
	self assert: obj2 other name equals: 'jim'
]

{ #category : #tests }
SSWReStoreStringDataIDTest >> test4Query [

	| matches |

	matches := self testInstances select: [ :e | e name = 'dave'].
	self assert: matches size equals: 1.
	self assert: matches first nmbr equals: 2.

	matches := self testInstances select: [ :e | e name = 'jon'].
	self assert: matches isEmpty
]

{ #category : #tests }
SSWReStoreStringDataIDTest >> test5QueryByExample [

	| template matches |

	template := self testClass new name: 'john'.

	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first nmbr equals: 7.

	template nmbr: 7.
	matches := template similarInstancesIn: reStore.
	self assert: matches size equals: 1.
	self assert: matches first name equals: 'john'.

	template nmbr: 100.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty.

	template := self testClass new name: 'jon'.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty.

	template nmbr: 7.
	matches := template similarInstancesIn: reStore.
	self assert: matches isEmpty
]

{ #category : #tests }
SSWReStoreStringDataIDTest >> test6VerifyIDInCopy [

	"Test issue where data ID value was not set in copyObject"

	| obj2 |

	obj2 := self testInstances detect: [:each | each nmbr = 2].

	self assert: obj2 _dbProxy _copyObject name equals: 'dave'.
	self assert: obj2 other _dbProxy _copyObject name equals: 'john'
]

{ #category : #tests }
SSWReStoreStringDataIDTest >> test7VerifyAssignedID [

	"Test an automatically-assigned ID makes it into a new instance when stored"

	| newObj recoveredObj |

	self testClass counter: 5.

	"Verify ID is fully assigned to new instances"
	newObj := self testClass new nmbr: 998.
	self assert: newObj name isNil.

	self assert: (newObj storeIn: reStore).
	self assert: newObj name equals: 'new 6'.
	self assert: newObj _dbProxy _copyObject name equals: 'new 6'.

	newObj := self testClass new nmbr: 999.
	self assert: newObj name isNil.
	self assert: (newObj storeIn: reStore).
	self assert: newObj name equals: 'new 7'.
	self assert: newObj _dbProxy _copyObject name equals: 'new 7'.

	reStore simulateReconnect.

	"Verify ID persisted in DB"
	recoveredObj := self testInstances detect: [ :e | e nmbr = 998].
	self assert: recoveredObj name equals: 'new 6'.

	recoveredObj := self testInstances detect: [ :e | e nmbr = 999].
	self assert: recoveredObj name equals: 'new 7'
]

{ #category : #constants }
SSWReStoreStringDataIDTest >> testClass [

	^ReStoreTestWithStringID
]
