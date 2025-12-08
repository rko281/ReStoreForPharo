Class {
	#name : 'SimplePersonWithEvents',
	#superclass : 'SimplePerson',
	#instVars : [
		'events'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'asserting' }
SimplePersonWithEvents class >> shouldInheritPersistency [ 

	^false
]

{ #category : 'testing' }
SimplePersonWithEvents >> actionMap [

	^events ifNil: [ events := IdentityDictionary new ]
]

{ #category : 'testing' }
SimplePersonWithEvents >> getEvents [

	^events
]

{ #category : 'testing' }
SimplePersonWithEvents >> hasLocalEvents [

	^events notNil and: [events isEmpty not]
]

{ #category : 'testing' }
SimplePersonWithEvents >> setEvents: aCollection [

	events := aCollection
]

{ #category : 'testing' }
SimplePersonWithEvents >> updateableActionMap [

	^self actionMap
]
