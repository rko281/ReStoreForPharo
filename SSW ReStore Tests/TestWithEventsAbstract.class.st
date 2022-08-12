Class {
	#name : #TestWithEventsAbstract,
	#superclass : #Test,
	#instVars : [
		'recoveryTime'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
TestWithEventsAbstract class >> shouldSubclassesInheritPersistency [

	^false
]

{ #category : #'event handling' }
TestWithEventsAbstract >> onRecovered [

	recoveryTime := DateAndTime now
]

{ #category : #accessing }
TestWithEventsAbstract >> recoveryTime [
	^recoveryTime
]

{ #category : #accessing }
TestWithEventsAbstract >> recoveryTime: anObject [
	recoveryTime := anObject
]
