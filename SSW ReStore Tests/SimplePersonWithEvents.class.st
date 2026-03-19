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

{ #category : 'accessing' }
SimplePersonWithEvents >> actionMap [

	^events ifNil: [ events := IdentityDictionary new ]
]

{ #category : 'accessing' }
SimplePersonWithEvents >> getEvents [

	^events
]

{ #category : 'testing' }
SimplePersonWithEvents >> hasLocalEvents [

	^events notNil and: [events isEmpty not]
]

{ #category : 'accessing' }
SimplePersonWithEvents >> setEvents: aCollection [

	events := aCollection
]

{ #category : 'accessing' }
SimplePersonWithEvents >> updateableActionMap [

	^self actionMap
]
