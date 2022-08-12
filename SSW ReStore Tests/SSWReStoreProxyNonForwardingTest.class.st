Class {
	#name : #SSWReStoreProxyNonForwardingTest,
	#superclass : #SSWReStoreHierarchyTest,
	#instVars : [
		'sup',
		'mid',
		'sub',
		'detailed',
		'simple',
		'simple2',
		'all',
		'transactionCriticalAction'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreProxyNonForwardingTest class >> allTestSelectors [

	^self testSelectors
]

{ #category : #running }
SSWReStoreProxyNonForwardingTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.

	aReStore
		addClass: SimplePerson;
		addClass: SimplePerson2;
		addClass: DetailedPerson.

	(aReStore tableForClass: SimplePerson) define: #orders as: (OrderedCollection of: Integer).
]

{ #category : #running }
SSWReStoreProxyNonForwardingTest >> createTestData [

	{(SimplePerson new firstName: 'simon'; surname: 'simple'). (SimplePerson2 new firstName: 'simon'; surname: 'simple'). (DetailedPerson new firstName: 'des'; surname: 'detailed')} storeAllIn: reStore.

	super createTestData.

	sup := (SuperPerson storedInstancesIn: reStore) withoutInheritance first.
	mid := (MidPerson storedInstancesIn: reStore) withoutInheritance first.
	sub := (SubPerson storedInstancesIn: reStore) first.
	detailed := (DetailedPerson storedInstancesIn: reStore) withoutInheritance first.
	simple := (SimplePerson storedInstancesIn: reStore) first.
	simple2 := (SimplePerson2 storedInstancesIn: reStore) first.

	all := {sup. mid. sub. detailed. simple. simple2}
]

{ #category : #helpers }
SSWReStoreProxyNonForwardingTest >> critical: aBlock [

	"Private - I'm pretending to be a Mutex"

	"Only do this once"
	transactionCriticalAction isNil ifFalse: 
		[transactionCriticalAction value.
		transactionCriticalAction := nil].

	^aBlock value
]

{ #category : #helpers }
SSWReStoreProxyNonForwardingTest >> critical: aBlock ifLocked: lockedBlock [

	"Private - I'm pretending to be a Mutex"

	^self critical: aBlock
]

{ #category : #helpers }
SSWReStoreProxyNonForwardingTest >> do: aBlock beforeTransactionCriticalIn: actionBlock [

	| mutex |

	mutex := reStore transactionMutex.
	transactionCriticalAction := aBlock.
	reStore transactionMutex: self.

	[actionBlock value] ensure: 
		[reStore transactionMutex: mutex.
		transactionCriticalAction := nil]
]

{ #category : #helpers }
SSWReStoreProxyNonForwardingTest >> prePreemptDuring: aBlock [

	"Private - Arrange for proxy forwarding methods to be pre-preempted right at the start (i.e. swapped before anything happens)"

	SSWDBProxy methodDictionary 
		at: #_dbProxyReStoreOrig put: (SSWDBProxy>>#_dbProxyReStore);
		at: #_dbProxyReStore put: (SSWDBProxy>>#_dbProxyReStorePrePreempt).
	SSWDBProxy flushMethodCache.

	aBlock ensure: 
		[SSWDBProxy methodDictionary at: #_dbProxyReStore put: (SSWDBProxy methodDictionary removeKey: #_dbProxyReStoreOrig).
		SSWDBProxy flushMethodCache].
]

{ #category : #helpers }
SSWReStoreProxyNonForwardingTest >> preemptAndSwapProxy: aProxy before: actionBlock [

	self do: [aProxy _swap] beforeTransactionCriticalIn: actionBlock
]

{ #category : #helpers }
SSWReStoreProxyNonForwardingTest >> readTestDataWithoutObjects [

	| ids |

	ids := all collect: [ :each | each _id].
	reStore simulateReconnect.

	sup := reStore createProxyForObjectOfClass: SuperPerson withID: ids first.
	mid := reStore createProxyForObjectOfClass: SuperPerson withID: ids second.
	sub := reStore createProxyForObjectOfClass: SuperPerson withID: ids third.
	detailed := reStore createProxyForObjectOfClass: SuperPerson withID: ids fourth.
	simple := reStore createProxyForObjectOfClass: SimplePerson withID: ids fifth.
	simple2 := reStore createProxyForObjectOfClass: SimplePerson2 withID: ids last.

	all := {sup. mid. sub. detailed. simple. simple2}.
	all do: [ :each | self assert: each _proxiedObject isNil]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testClassPrePreempted [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	self prePreemptDuring: 
		[self assert: simple class equals: SimplePerson.
		self assert: simple2 class equals: SimplePerson2.
		self assert: sup class equals: SuperPerson.
		self assert: mid class equals: MidPerson.
		self assert: sub class equals: SubPerson.
		self assert: detailed class equals: DetailedPerson]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testClassPreempted [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	self preemptAndSwapProxy: simple before: [self assert: simple class equals: SimplePerson].
	self preemptAndSwapProxy: simple2 before: [self assert: simple2 class equals: SimplePerson2].
	self preemptAndSwapProxy: sup before: [self assert: sup class equals: SuperPerson].
	self preemptAndSwapProxy: mid before: [self assert: mid class equals: MidPerson].
	self preemptAndSwapProxy: sub before: [self assert: sub class equals: SubPerson].
	self preemptAndSwapProxy: detailed before: [self assert: detailed class equals: DetailedPerson]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testClassWithObject [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	self assert: sup class equals: SuperPerson.
	self assert: mid class equals: MidPerson.
	self assert: sub class equals: SubPerson.
	self assert: simple class equals: SimplePerson.
	self assert: simple2 class equals: SimplePerson2.
	self assert: detailed class equals: DetailedPerson.

	all do: [ :each | self assert: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testClassWithoutObject [

	| supers |

	self readTestDataWithoutObjects.

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject isNil].
	supers := all first: 4.
	supers do: [ :each | self assert: each _class equals: SuperPerson].
	self assert: simple _class = SimplePerson.
	self assert: simple2 _class = SimplePerson2.

	self assert: sup class equals: SuperPerson.
	self assert: mid class equals: MidPerson.
	self assert: sub class equals: SubPerson.
	self assert: detailed class equals: DetailedPerson.
	self assert: simple class equals: SimplePerson.
	self assert: simple2 class equals: SimplePerson2.

	all do: [ :each | self assert: each isDBProxy].
	self assert: simple _proxiedObject isNil.
	self assert: simple2 _proxiedObject isNil.

	"We have to read a hierarchy object to get the class"
	supers do: [ :each | self deny: each _proxiedObject isNil]. 

	"Ensure class has been pushed into proxy"
	supers do: [ :each | self assert: each _class equals: each _proxiedObject class]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testDebugPrintStringPrePreempted [

	| expectedPrintStrings |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	expectedPrintStrings := all collect: [ :each | each _proxiedObject debugPrintString].

	self prePreemptDuring: [all with: expectedPrintStrings do: [ :each :expected | self assert: each debugPrintString equals: expected]].

	all do: [ :each | self deny: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testDebugPrintStringPreempted [

	| expectedPrintStrings |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	expectedPrintStrings := all collect: [ :each | each _proxiedObject debugPrintString].

	all with: expectedPrintStrings do: [ :each :expected | self preemptAndSwapProxy: each before: [self assert: each debugPrintString equals: expected]].

	all do: [ :each | self deny: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testDebugPrintStringWithObject [

	| expectedPrintStrings |

	expectedPrintStrings := all collect: [ :each | each _debugPrintString].
	all with: expectedPrintStrings do: [ :each :expected | self assert: each debugPrintString equals: expected].

	"With the object, hierarchy objects know their exact class"
	self assert: (sup debugPrintString beginsWith: '<a SuperPerson').
	self assert: (mid debugPrintString beginsWith: '<a MidPerson').
	self assert: (sub debugPrintString beginsWith: '<a SubPerson').
	self assert: (detailed debugPrintString beginsWith: '<a DetailedPerson').

	all do: [ :each | self assert: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testDebugPrintStringWithoutObject [

	| expectedPrintStrings |

	self readTestDataWithoutObjects.

	expectedPrintStrings := all collect: [ :each | each _debugPrintString].
	all with: expectedPrintStrings do: [ :each :expected | self assert: each debugPrintString equals: expected].

	"Without the object, hierarchy objects don't know their exact class"
	(all first: 4) do: [ :each | self assert: ('<an unrecovered SuperPerson*>' match: each debugPrintString)].

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject isNil]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testEqualsPreempted [

	"= rather than assert:equals: is deliberate in this method"

	self assert: simple isDBProxy.
	self preemptAndSwapProxy: simple before: [self deny: (simple = simple2)].

	self assert: simple2 isDBProxy.
	self preemptAndSwapProxy: simple2 before: [self assert: (simple2 = simple)].

	self assert: sub isDBProxy.
	self preemptAndSwapProxy: sub before: [self deny: (sub = mid)].

	self assert: detailed isDBProxy.
	self preemptAndSwapProxy: detailed before: [self deny: (detailed = mid)]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testEqualsWithObject [

	"= rather than assert:equals: is deliberate in this method"

	"SimplePerson has standard Object>>#= (identity) comparison so does not need to swap"
	self deny: (simple = simple2).
	self assert: simple isDBProxy.

	"SimplePerson2 has custom = comparison so needs to swap"
	self assert: (simple2 = simple).
	self deny: simple2 isDBProxy.

	"SubPerson has standard Object>>#= (identity) comparison so does not need to swap"
	self deny: (sub = mid).
	self assert: sub isDBProxy.

	"DetailedPerson2 has custom = comparison so needs to swap"
	self deny: (detailed = mid).
	self deny: detailed isDBProxy.
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testEqualsWithoutObject [

	"= rather than assert:equals: is deliberate in this method"

	self readTestDataWithoutObjects.

	"SimplePerson has standard Object>>#= (identity) comparison so does not need to fetch"
	self deny: (simple = simple2).
	self assert: simple isDBProxy.
	self assert: simple _proxiedObject isNil.

	"SimplePerson2 has custom = comparison so needs to fetch"
	self assert: (simple2 = simple).
	self deny: simple2 isDBProxy.

	"SubPerson has standard Object>>#= (identity) comparison but needs to fetch to determine class"
	self deny: (sub = mid).
	self deny: sub isDBProxy.

	"DetailedPerson2 has custom = comparison so needs to fetch"
	self deny: (detailed = mid).
	self deny: detailed isDBProxy.
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testHashPrePreempted [

	self prePreemptDuring: 
		[| expectedHash |

		expectedHash := simple identityHash.
		self assert: simple isDBProxy.
		self assert: simple hash equals: expectedHash.

		expectedHash := simple2 _proxiedObject fullName hash.
		self assert: simple2 isDBProxy.
		self assert: simple2 hash equals: expectedHash.

		expectedHash := sub identityHash.
		self assert: sub isDBProxy.
		self assert: sub hash equals: expectedHash.

		expectedHash := detailed _proxiedObject fullName hash.
		self assert: detailed isDBProxy.
		self assert: detailed hash equals: expectedHash]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testHashPreempted [

	| expectedHash |

	expectedHash := simple identityHash.
	self assert: simple isDBProxy.
	self preemptAndSwapProxy: simple before: [self assert: simple hash equals: expectedHash].

	expectedHash := simple2 _proxiedObject fullName hash.
	self assert: simple2 isDBProxy.
	self preemptAndSwapProxy: simple2 before: [self assert: simple2 hash equals: expectedHash].

	expectedHash := sub identityHash.
	self assert: sub isDBProxy.
	self preemptAndSwapProxy: sub before: [self assert: sub hash equals: expectedHash].

	expectedHash := detailed _proxiedObject fullName hash.
	self assert: detailed isDBProxy.
	self preemptAndSwapProxy: detailed before: [self assert: detailed hash equals: expectedHash]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testHashWithObject [

	| expectedHash |

	"SimplePerson has standard Object>>#hash so does not need to swap"
	expectedHash := simple identityHash.
	self assert: simple isDBProxy.
	self assert: simple hash equals: expectedHash.
	self assert: simple isDBProxy.

	"SimplePerson2 has custom hash so needs to swap"
	expectedHash := simple2 _proxiedObject fullName hash.
	self assert: simple2 isDBProxy.
	self assert: simple2 hash equals: expectedHash.
	self deny: simple2 isDBProxy.

	"SubPerson has standard Object>>#hash so does not need to swap"
	expectedHash := sub identityHash.
	self assert: sub isDBProxy.
	self assert: sub hash equals: expectedHash.
	self assert: sub isDBProxy.

	"DetailedPerson2 has custom hash so needs to swap"
	expectedHash := detailed _proxiedObject fullName hash.
	self assert: detailed isDBProxy.
	self assert: detailed hash equals: expectedHash.
	self deny: detailed isDBProxy.
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testHashWithoutObject [

	| expectedHash |

	self readTestDataWithoutObjects.

	"SimplePerson has standard Object>>#hash so does not need to fetch"
	expectedHash := simple identityHash.
	self assert: simple isDBProxy.
	self assert: simple hash equals: expectedHash.
	self assert: simple isDBProxy.

	"SimplePerson2 has custom hash so needs to fetch"
	self assert: simple2 hash class equals: SmallInteger.
	self deny: simple2 isDBProxy.

	"SubPerson has standard Object>>#hash but needs to fetch to determine class"
	expectedHash := sub identityHash.
	self assert: sub isDBProxy.
	self assert: sub hash equals: expectedHash.
	self deny: sub isDBProxy.

	"DetailedPerson2 has custom hash so needs to swap"
	self assert: detailed hash class = SmallInteger.
	self deny: detailed isDBProxy.
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfCollectionPrePreempted [

	simple orders size.
	reStore rollbackTransaction.

	self assert: simple orders isDBProxy.
	self assert: simple orders _proxiedObject notNil.

	self prePreemptDuring: [self assert: (simple orders isKindOf: Collection)]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfCollectionPreempted [

	simple orders size.
	reStore rollbackTransaction.

	self assert: simple orders isDBProxy.
	self assert: simple orders _proxiedObject notNil.

	self preemptAndSwapProxy: simple orders before: [self assert: (simple orders isKindOf: Collection)]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfPrePreempted [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	self prePreemptDuring: 
		[self assert: (simple isKindOf: SimplePerson).
		(all first: 4) do: [ :each | self assert: (each isKindOf: SuperPerson)]]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfPreempted [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	self preemptAndSwapProxy: simple before: [self assert: (simple isKindOf: SimplePerson)].
	(all first: 4) do: [ :each | self preemptAndSwapProxy: each before: [self assert: (each isKindOf: SuperPerson)]]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfWithCollection [

	simple orders size.
	reStore rollbackTransaction.

	self assert: simple orders isDBProxy.
	self assert: simple orders _proxiedObject notNil.

	self assert: (simple orders isKindOf: Collection).
	self assert: (simple orders isKindOf: OrderedCollection).
	self deny: (simple orders isKindOf: Array).
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfWithObject [

	| supers |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	self assert: (simple isKindOf: SimplePerson).
	self deny: (simple isKindOf: SuperPerson).

	self assert: (simple2 isKindOf: SimplePerson2).
	self deny: (simple2 isKindOf: SuperPerson).

	supers := all first: 4.
	supers do: [ :each | self assert: (each isKindOf: SuperPerson)].
	supers do: [ :each | self deny: (each isKindOf: SimplePerson)].

	self assert: (mid isKindOf: MidPerson).
	self deny: (mid isKindOf: SubPerson).

	self assert: (sub isKindOf: MidPerson).
	self assert: (sub isKindOf: SubPerson).

	all do: [ :each | self assert: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfWithoutCollection [

	self assert: simple orders isDBProxy.
	self assert: simple orders _proxiedObject isNil.

	self assert: (simple orders isKindOf: Collection).
	self assert: (simple orders isKindOf: OrderedCollection).
	self deny: (simple orders isKindOf: Array).
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testIsKindOfWithoutObject [

	| supers |

	self readTestDataWithoutObjects.

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject isNil].
	supers := all first: 4.

	self assert: (simple isKindOf: SimplePerson).
	self deny: (simple isKindOf: SuperPerson).
	self assert: simple isDBProxy.
	self assert: simple _proxiedObject isNil.

	supers := all first: 4.
	supers do: [ :each | self assert: (each isKindOf: SuperPerson)].
	supers do: [ :each | self deny: (each isKindOf: SimplePerson)].

	self assert: (mid isKindOf: MidPerson).
	self deny: (mid isKindOf: SubPerson).

	self assert: (sub isKindOf: MidPerson).
	self assert: (sub isKindOf: SubPerson).

	self assert: (detailed isKindOf: DetailedPerson).
	self deny: (detailed isKindOf: SubPerson).

	supers do: [ :each | self assert: each isDBProxy].

	"We have to read a hierarchy object to get the class"
	supers do: [ :each | self deny: each _proxiedObject isNil]. 

	"Ensure class has been pushed into proxy"
	supers do: [ :each | self assert: each _class equals: each _proxiedObject class]. 
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintOnPrePreempted [

	| expectedPrintStrings |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	expectedPrintStrings := all collect: [ :each | each _proxiedObject printString].

	self prePreemptDuring: 
		[all with: expectedPrintStrings do: 
			[ :each :expected || stream | 
			stream := WriteStream on: String new. 
			each printOn: stream. self assert: stream contents equals: expected]].

	all do: [ :each | self deny: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintOnPreempted [

	| expectedPrintStrings |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	expectedPrintStrings := all collect: [ :each | each _proxiedObject printString].

	all with: expectedPrintStrings do: 
		[ :each :expected || stream | 
		stream := WriteStream on: String new. 
		self preemptAndSwapProxy: each before: [each printOn: stream. self assert: stream contents equals: expected]].

	all do: [ :each | self deny: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintOnWithObject [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	all do: [ :each || stream | stream := WriteStream on: String new. each printOn: stream. self assert: stream contents equals: each _proxiedObject printString].

	all do: [ :each | self assert: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintOnWithoutObject [

	| stream |

	self readTestDataWithoutObjects.

	all := {sup. mid. sub. simple. simple2. detailed}.
	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject isNil].

	"Most classes have the standard printString/printOn: combo"
	(all allButLast: 2) do: [ :each | stream := WriteStream on: String new. each printOn: stream. self assert: stream contents equals: 'a ', each _class name].

	"SimplePerson2 has a custom printOn:"
	stream := WriteStream on: String new. 
	simple2 printOn: stream.
	self assert: stream contents equals: 'a SimplePerson2(simon simple)'.

	"DetailedPerson has a custom printOn:"
	stream := WriteStream on: String new. 
	detailed printOn: stream.
	self assert: stream contents equals: 'a DetailedPerson(des detailed)'.

	all do: 
		[ :each | 
		self assert: each isDBProxy.
		each == simple
			ifTrue: ["Can get the printString without needing the proxiedObject" self assert: each _proxiedObject isNil]
			ifFalse: ["Needs the proxiedObject to determine the class and/or printString"	self deny: detailed _proxiedObject isNil]]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintStringPrePreempted [

	| expectedPrintStrings |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	expectedPrintStrings := all collect: [ :each | each _proxiedObject printString].

	self prePreemptDuring: [all with: expectedPrintStrings do: [ :each :expected | self assert: each printString equals: expected]].

	all do: [ :each | self deny: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintStringPreempted [

	| expectedPrintStrings |

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	expectedPrintStrings := all collect: [ :each | each _proxiedObject printString].

	all with: expectedPrintStrings do: [ :each :expected | self preemptAndSwapProxy: each before: [self assert: each printString equals: expected]].

	all do: [ :each | self deny: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintStringWithObject [

	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject notNil].

	all do: [ :each | self assert: each printString equals: each _proxiedObject printString].

	all do: [ :each | self assert: each isDBProxy]
]

{ #category : #'unit tests' }
SSWReStoreProxyNonForwardingTest >> testPrintStringWithoutObject [

	self readTestDataWithoutObjects.

	all := {sup. mid. sub. simple. detailed}.
	all do: [ :each | self assert: each isDBProxy].
	all do: [ :each | self assert: each _proxiedObject isNil].

	"Most classes have the standard printString/printOn: combo"
	(all allButLast: 2) do: [ :each | self assert: each printString equals: 'a ', each _class name].

	"SimplePerson2 has a custom printOn:"
	self assert: simple2 printString equals: 'a SimplePerson2(simon simple)'.

	"DetailedPerson has a custom printOn:"
	self assert: detailed printString equals: 'a DetailedPerson(des detailed)'.

	all do: 
		[ :each | 
		self assert: each isDBProxy.
		each == simple
			ifTrue: ["Can get the printString without needing the proxiedObject" self assert: each _proxiedObject isNil]
			ifFalse: ["Needs the proxiedObject to determine the class and/or printString"	self deny: detailed _proxiedObject isNil]]
]
