Class {
	#name : #TestWithEventsItem,
	#superclass : #TestWithEventsAbstract,
	#instVars : [
		'owner'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #'event handling' }
TestWithEventsItem >> onAboutToUnstore [

	self name: '<unstored>'
]

{ #category : #'event handling' }
TestWithEventsItem >> onUnstored [

	owner isNil ifFalse: [owner removeItem: self]
]

{ #category : #accessing }
TestWithEventsItem >> owner [
	^owner
]

{ #category : #accessing }
TestWithEventsItem >> owner: anObject [
	owner := anObject
]
