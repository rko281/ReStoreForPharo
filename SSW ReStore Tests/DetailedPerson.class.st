"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #DetailedPerson,
	#superclass : #SuperPerson,
	#instVars : [
		'dob',
		'dateOfBirth',
		'friend',
		'bestFriend'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
DetailedPerson class >> reStoreDefinition [

	| definition | 

	definition := super reStoreDefinition.

	self useDateOfBirth
		ifTrue: [definition define: #dateOfBirth as: Date]
		ifFalse: [definition define: #dob as: Date].

	self useBestFriend
		ifTrue: [definition define: #bestFriend as: DetailedPerson]
		ifFalse: [definition define: #friend as: DetailedPerson].

	^definition
]

{ #category : #public }
DetailedPerson class >> useBestFriend [

	^DetailedPerson2 useBestFriend
]

{ #category : #public }
DetailedPerson class >> useDateOfBirth [

	^DetailedPerson2 useDateOfBirth
]

{ #category : #accessing }
DetailedPerson >> bestFriend [
	^bestFriend
]

{ #category : #accessing }
DetailedPerson >> bestFriend: anObject [
	bestFriend := anObject
]

{ #category : #accessing }
DetailedPerson >> dateOfBirth [
	^dateOfBirth
]

{ #category : #accessing }
DetailedPerson >> dateOfBirth: anObject [
	dateOfBirth := anObject
]

{ #category : #accessing }
DetailedPerson >> dob [
	^dob
]

{ #category : #accessing }
DetailedPerson >> dob: anObject [
	dob := anObject
]

{ #category : #accessing }
DetailedPerson >> friend [
	^friend
]

{ #category : #accessing }
DetailedPerson >> friend: anObject [
	friend := anObject
]
