Class {
	#name : 'TestWithEvents',
	#superclass : 'TestWithEventsAbstract',
	#instVars : [
		'items',
		'count'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
TestWithEvents class >> reStoreDefinition [

	^super reStoreDefinition
		define: #items as: (OrderedCollection of: TestWithEventsItem related);
		yourself
]

{ #category : 'accessing' }
TestWithEvents >> _count [
	^count
]

{ #category : 'accessing' }
TestWithEvents >> count [
	^count ifNil: [count := self items size]
]

{ #category : 'accessing' }
TestWithEvents >> items [
	^items
]

{ #category : 'accessing' }
TestWithEvents >> items: anObject [
	items := anObject
]

{ #category : 'event handling' }
TestWithEvents >> onRecovered [

	super onRecovered.
	count := self items size
]

{ #category : 'event handling' }
TestWithEvents >> onRefresh [

	count := self items size
]

{ #category : 'event handling' }
TestWithEvents >> onRollback [

	count := nil
]

{ #category : 'removing' }
TestWithEvents >> removeItem: anItem [

	self count.
	self items remove: anItem.
	count := count - 1
]
