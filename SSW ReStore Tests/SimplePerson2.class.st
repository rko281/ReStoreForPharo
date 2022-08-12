"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SimplePerson2,
	#superclass : #Object,
	#instVars : [
		'firstName',
		'forename',
		'surname',
		'emailAddress',
		'time',
		'friend',
		'bestFriend',
		'notes'
	],
	#classInstVars : [
		'useForename',
		'useBestFriend',
		'useLongNotes',
		'useNotes'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SimplePerson2 class >> new [

	^super new
		time: DateAndTime now;
		yourself
]

{ #category : #accessing }
SimplePerson2 class >> notesSize [

	^self useLongNotes 
		ifTrue: [20]
		ifFalse: [10]
]

{ #category : #public }
SimplePerson2 class >> reStoreDefinition [

	| definition |

	definition := super reStoreDefinition.

	definition
		define: #surname as: (String maxSize: 100).

	self useForename
		ifTrue: [definition define: #forename as: (String maxSize: 100)]
		ifFalse: [definition define: #firstName as: (String maxSize: 100)].

	definition
		define: #emailAddress as: (String maxSize: 100);
		define: #time as: DateAndTime.

	self useBestFriend
		ifTrue: [definition define: #bestFriend as: SimplePerson2]
		ifFalse: [definition define: #friend as: SimplePerson2].

	self useNotes ifTrue: [definition define: #notes as: (String maxSize: self notesSize)].

	^definition
]

{ #category : #public }
SimplePerson2 class >> useBestFriend [

	^useBestFriend ifNil: [false]
]

{ #category : #public }
SimplePerson2 class >> useBestFriend: aBoolean [

	useBestFriend := aBoolean
]

{ #category : #public }
SimplePerson2 class >> useForename [

	^useForename ifNil: [false]
]

{ #category : #public }
SimplePerson2 class >> useForename: aBoolean [

	useForename := aBoolean
]

{ #category : #accessing }
SimplePerson2 class >> useLongNotes [
	^useLongNotes ifNil: [false]
]

{ #category : #accessing }
SimplePerson2 class >> useLongNotes: anObject [
	useLongNotes := anObject
]

{ #category : #public }
SimplePerson2 class >> useNotes [

	^useNotes ifNil: [false]
]

{ #category : #public }
SimplePerson2 class >> useNotes: aBoolean [

	useNotes := aBoolean
]

{ #category : #comparing }
SimplePerson2 >> = aDetailedPerson [

	^self fullName = aDetailedPerson fullName
]

{ #category : #accessing }
SimplePerson2 >> bestFriend [
	^bestFriend
]

{ #category : #accessing }
SimplePerson2 >> bestFriend: anObject [
	bestFriend := anObject
]

{ #category : #displaying }
SimplePerson2 >> displayOn: aStream [

	aStream display: self firstName; space; display: self surname
]

{ #category : #accessing }
SimplePerson2 >> emailAddress [
	"Private - Answer the value of the receiver's ''emailAddress'' instance variable."

	^emailAddress
]

{ #category : #accessing }
SimplePerson2 >> emailAddress: anObject [
	"Private - Set the value of the receiver's ''emailAddress'' instance variable to the argument, anObject."

	emailAddress := anObject
]

{ #category : #accessing }
SimplePerson2 >> firstName [
	"Private - Answer the value of the receiver's ''firstName'' instance variable."

	^firstName
]

{ #category : #accessing }
SimplePerson2 >> firstName: anObject [
	"Private - Set the value of the receiver's ''firstName'' instance variable to the argument, anObject."

	firstName := anObject
]

{ #category : #accessing }
SimplePerson2 >> forename [
	"Private - Answer the value of the receiver's ''forename'' instance variable."

	^forename
]

{ #category : #accessing }
SimplePerson2 >> forename: anObject [
	"Private - Set the value of the receiver's ''forename'' instance variable to the argument, anObject."

	forename := anObject
]

{ #category : #accessing }
SimplePerson2 >> friend [
	^friend
]

{ #category : #accessing }
SimplePerson2 >> friend: anObject [
	friend := anObject
]

{ #category : #accessing }
SimplePerson2 >> fullName [

	^SimplePerson2 useForename 
		ifTrue: [self forename, ' ', self surname]
		ifFalse: [self firstName, ' ', self surname]
]

{ #category : #comparing }
SimplePerson2 >> hash [

	^self fullName hash
]

{ #category : #accessing }
SimplePerson2 >> notes [
	^notes
]

{ #category : #accessing }
SimplePerson2 >> notes: anObject [
	notes := anObject
]

{ #category : #displaying }
SimplePerson2 >> printOn: aStream [
	"Answer the name of the receiver as a developer would wish to see it ."

	super printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $).
]

{ #category : #accessing }
SimplePerson2 >> surname [
	"Private - Answer the value of the receiver's ''surname'' instance variable."

	^surname
]

{ #category : #accessing }
SimplePerson2 >> surname: anObject [
	"Private - Set the value of the receiver's ''surname'' instance variable to the argument, anObject."

	surname := anObject
]

{ #category : #accessing }
SimplePerson2 >> time [
	"Private - Answer the value of the receiver's ''time'' instance variable."

	^time
]

{ #category : #accessing }
SimplePerson2 >> time: anObject [
	"Private - Set the value of the receiver's ''time'' instance variable to the argument, anObject."

	time := anObject
]
