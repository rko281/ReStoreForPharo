"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #DetailedPerson2,
	#superclass : #SuperPerson,
	#instVars : [
		'dob',
		'dateOfBirth',
		'friend',
		'bestFriend',
		'notes'
	],
	#classInstVars : [
		'useDateOfBirth',
		'useBestFriend',
		'useLongNotes'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
DetailedPerson2 class >> notesSize [

	^self useLongNotes 
		ifTrue: [60]
		ifFalse: [40]
]

{ #category : #public }
DetailedPerson2 class >> reStoreDefinition [

	| definition |

	definition := super reStoreDefinition.

	self useDateOfBirth
		ifTrue: [definition define: #dateOfBirth as: Date]
		ifFalse: [definition define: #dob as: Date].

	self useBestFriend
		ifTrue: [definition define: #bestFriend as: DetailedPerson2]
		ifFalse: [definition define: #friend as: DetailedPerson2].

	definition define: #notes as: (String maxSize: self notesSize).
		
	^definition
]

{ #category : #public }
DetailedPerson2 class >> useBestFriend [

	^useBestFriend ifNil: [false]
]

{ #category : #public }
DetailedPerson2 class >> useBestFriend: aBoolean [

	useBestFriend := aBoolean
]

{ #category : #accessing }
DetailedPerson2 class >> useDateOfBirth [
	^useDateOfBirth ifNil: [false]
]

{ #category : #accessing }
DetailedPerson2 class >> useDateOfBirth: anObject [
	useDateOfBirth := anObject
]

{ #category : #accessing }
DetailedPerson2 class >> useLongNotes [
	^useLongNotes ifNil: [false]
]

{ #category : #accessing }
DetailedPerson2 class >> useLongNotes: anObject [
	useLongNotes := anObject
]

{ #category : #accessing }
DetailedPerson2 >> bestFriend [
	^bestFriend
]

{ #category : #accessing }
DetailedPerson2 >> bestFriend: anObject [
	bestFriend := anObject
]

{ #category : #accessing }
DetailedPerson2 >> dateOfBirth [
	^dateOfBirth
]

{ #category : #accessing }
DetailedPerson2 >> dateOfBirth: anObject [
	dateOfBirth := anObject
]

{ #category : #accessing }
DetailedPerson2 >> dob [
	^dob
]

{ #category : #accessing }
DetailedPerson2 >> dob: anObject [
	dob := anObject
]

{ #category : #accessing }
DetailedPerson2 >> friend [
	^friend
]

{ #category : #accessing }
DetailedPerson2 >> friend: anObject [
	friend := anObject
]

{ #category : #accessing }
DetailedPerson2 >> notes [
	^notes
]

{ #category : #accessing }
DetailedPerson2 >> notes: anObject [
	notes := anObject
]
