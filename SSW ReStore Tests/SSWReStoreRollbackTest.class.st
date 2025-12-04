Class {
	#name : 'SSWReStoreRollbackTest',
	#superclass : 'SSWReStoreAbstractQueryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackChanges [

	| person rolledBack |

	person := self john.
	rolledBack := false.
	person rollbackBlock: [rolledBack := true].

	reStore beginTransaction.
	person firstName: 'Jon'.
	reStore rollbackTransaction.

	"Following the rollback the object should be an unchanged proxy which has had #onRollback invoked on it"
	self assert: rolledBack.
	self assert: person isDBProxy.
	self assert: person _isPersistent.
	self assert: ((reStore classCacheFor: person class) includes: person).
	self assert: person firstName equals: 'John'
]

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackStore [

	| newPerson rolledBack |

	newPerson := SimplePerson new firstName: 'Partario'.
	rolledBack := false.
	newPerson rollbackBlock: [rolledBack := true].

	reStore beginTransaction.
	newPerson storeIn: reStore.
	reStore rollbackTransaction.

	"Following the rollback the object should not be a proxy which has had #onRollback invoked on it, and no proxy for it should exist"
	self assert: rolledBack.
	self deny: newPerson isDBProxy.
	self deny: ((reStore classCacheFor: newPerson class) anySatisfy: [ :each | each _proxiedObject == newPerson])
]

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackUnstore [

	| person rolledBack |

	person := self john.
	rolledBack := false.
	person rollbackBlock: [rolledBack := true].

	reStore beginTransaction.
	person unstore.
	reStore rollbackTransaction.

	"Following the rollback the object should be an unchanged proxy which has had #onRollback invoked on it"
	self assert: rolledBack.
	self assert: person isDBProxy.
	self assert: person _isPersistent.
	self assert: ((reStore classCacheFor: person class) includes: person).
]
