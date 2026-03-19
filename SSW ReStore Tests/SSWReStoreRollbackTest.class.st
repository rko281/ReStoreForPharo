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
SSWReStoreRollbackTest >> testRollbackChangesPreservesEventsInRegister [

	"Verify a rollback preserves events stored in the _EventsRegister / EventManager"

	| person rolledBack |

	person := self john.
	rolledBack := false.
	person when: #someEvent send: #value to: [rolledBack := true].
	
	reStore beginTransaction.
	person firstName: 'Jon'.
	reStore rollbackTransaction.

	"Verify the event is still present"
	person trigger: #someEvent.
	self assert: rolledBack
]

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackChangesPreservesLocalEvents [

	"Verify a rollback preserves events stored locally in the object"

	| person rolledBack |

	(reStore addClass: SimplePersonWithEvents) name: (reStore tableForClass: SimplePerson) name.
	reStore tableCache removeKey: SimplePerson.

	person := (SimplePersonWithEvents storedInstancesIn: reStore) detect: [ :each | each firstName = 'John'].
	rolledBack := false.
	person when: #someEvent send: #value to: [rolledBack := true].
	self assert: person hasLocalEvents.
	
	reStore beginTransaction.
	person firstName: 'Jon'.
	reStore rollbackTransaction.

	"Verify the event is still present"
	person trigger: #someEvent.
	self assert: rolledBack.
	self assert: person hasLocalEvents
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
SSWReStoreRollbackTest >> testRollbackStorePreservesEventsInRegister [

	"Verify a rollback preserves events stored in the _EventsRegister / EventManager"

	| newPerson rolledBack |

	newPerson := SimplePerson new firstName: 'Partario'.
	rolledBack := false.
	newPerson when: #someEvent send: #value to: [rolledBack := true].

	reStore beginTransaction.
	newPerson storeIn: reStore.
	reStore rollbackTransaction.

	"Verify the event is still present"
	newPerson trigger: #someEvent.
	self assert: rolledBack
]

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackStorePreservesLocalEvents [

	"Verify a rollback preserves events stored locally in the object"

	| newPerson rolledBack |

	(reStore addClass: SimplePersonWithEvents) name: (reStore tableForClass: SimplePerson) name.
	reStore tableCache removeKey: SimplePerson.

	newPerson := SimplePersonWithEvents new firstName: 'Partario'.
	rolledBack := false.
	newPerson when: #someEvent send: #value to: [rolledBack := true].
	self assert: newPerson hasLocalEvents.

	reStore beginTransaction.
	newPerson storeIn: reStore.
	reStore rollbackTransaction.

	"Verify the event is still present"
	newPerson trigger: #someEvent.
	self assert: rolledBack.
	self assert: newPerson hasLocalEvents
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

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackUnstorePreservesEventsInRegister [

	"Verify a rollback preserves events stored in the _EventsRegister / EventManager"

	| person rolledBack |

	person := self john.
	rolledBack := false.
	person when: #someEvent send: #value to: [rolledBack := true].
	
	reStore beginTransaction.
	person unstore.
	reStore rollbackTransaction.

	"Verify the event is still present"
	person trigger: #someEvent.
	self assert: rolledBack
]

{ #category : 'tests' }
SSWReStoreRollbackTest >> testRollbackUnstorePreservesLocalEvents [

	"Verify a rollback preserves events stored locally in the object"

	| person rolledBack |

	(reStore addClass: SimplePersonWithEvents) name: (reStore tableForClass: SimplePerson) name.
	reStore tableCache removeKey: SimplePerson.

	person := (SimplePersonWithEvents storedInstancesIn: reStore) detect: [ :each | each firstName = 'John'].
	rolledBack := false.
	person when: #someEvent send: #value to: [rolledBack := true].
	self assert: person hasLocalEvents.
	
	reStore beginTransaction.
	person unstore.
	reStore rollbackTransaction.

	"Verify the event is still present"
	person trigger: #someEvent.
	self assert: rolledBack.
	self assert: person hasLocalEvents
]
