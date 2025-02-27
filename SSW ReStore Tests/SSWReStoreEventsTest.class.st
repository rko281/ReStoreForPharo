Class {
	#name : 'SSWReStoreEventsTest',
	#superclass : 'SSWReStore2Test',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'helpers' }
SSWReStoreEventsTest >> _testOnRecovery [

	| obj |

	obj := (TestWithEvents storedInstancesIn: reStore) first.

	self assert: obj name = 'test'.
	self assert: obj _count notNil.
	self assert: obj _count equals: obj items size.

	^obj
]

{ #category : 'running' }
SSWReStoreEventsTest >> addClassesTo: aReStore [

	aReStore
		addClass: TestWithEvents;
		addClass: TestWithEventsItem
]

{ #category : 'running' }
SSWReStoreEventsTest >> createTestData [

	TestWithEvents new
		name: 'test';
		items: ((1 to: 5) collect: [ :index | TestWithEventsItem new name: index displayString; yourself]);
		storeIn: reStore.

	reStore simulateReconnect
]

{ #category : 'unit tests' }
SSWReStoreEventsTest >> testOnAboutToUnstore [

	| obj toUnstore prevCount |

	obj := self _testOnRecovery.
	prevCount := obj count.

	toUnstore := obj items last.

	reStore beginTransaction.
	toUnstore owner: obj; unstore.
	self assert: toUnstore name equals: '<unstored>'.

	"onUnstored should not have triggered yet"
	self assert: (obj items includes: toUnstore).

	reStore commitTransaction.

	"onUnstored on item should now have updated obj"
	self assert: obj _count notNil.
	self assert: obj count equals: prevCount - 1.
	self deny: (obj items includes: toUnstore)
]

{ #category : 'unit tests' }
SSWReStoreEventsTest >> testOnRecovery [

	| now obj |

	now := DateAndTime now.

	obj := self _testOnRecovery.

	"Also test onRecovered setting recoveryTime"
	self assert: (obj recoveryTime >= now).
	obj items do: [ :each | self assert: each recoveryTime >= now]
]

{ #category : 'unit tests' }
SSWReStoreEventsTest >> testOnRefresh [

	| obj prevCount obj2 |

	obj := self _testOnRecovery.
	prevCount := obj count.

	"update in other session"
	obj2 := (TestWithEvents storedInstancesIn: reStore2) first.
	obj2 items add: (TestWithEventsItem new name: '99').
	obj2 store.

	self assert: obj _count equals: prevCount.

	"onRefresh should nil the cache"
	obj refresh.
	self assert: obj _count isNil.
	self assert: obj count equals: prevCount + 1
]

{ #category : 'unit tests' }
SSWReStoreEventsTest >> testOnRollback [

	| now obj prevCount |

	obj := self _testOnRecovery.
	prevCount := obj count.
	(Delay forMilliseconds: 10) wait.
	now := DateAndTime now.
	
	"update"
	obj items removeLast.

	self assert: obj _count equals: prevCount.

	"onRollback should nil the cache"
	obj refresh.
	self assert: obj _count isNil.
	self assert: obj count equals: prevCount.

	"...but not reset recoveryTime"
	self assert: (obj recoveryTime < now).
	obj items do: [ :each | self assert: (each recoveryTime < now)]
]

{ #category : 'unit tests' }
SSWReStoreEventsTest >> testOnUnstore [

	| obj toUnstore prevCount |

	obj := self _testOnRecovery.
	prevCount := obj count.

	toUnstore := obj items last.
	toUnstore owner: obj; unstore.

	"onUnstored on item should have updated obj"
	self assert: obj _count notNil.
	self assert: obj count equals: prevCount - 1.
	self deny: (obj items includes: toUnstore)
]
