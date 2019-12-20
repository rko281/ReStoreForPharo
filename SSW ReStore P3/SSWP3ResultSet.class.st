Class {
	#name : #SSWP3ResultSet,
	#superclass : #P3Result,
	#instVars : [
		'query'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #'initialize-release' }
SSWP3ResultSet >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : #enumerating }
SSWP3ResultSet >> do: aBlock [

	data do: [ :vals | aBlock value: (self rowWith: vals)]
]

{ #category : #enumerating }
SSWP3ResultSet >> first [

	^data isEmpty 
		ifTrue: [nil] 
		ifFalse: [self rowWith: data first]
]

{ #category : #accessing }
SSWP3ResultSet >> last [

	^data isEmpty 
		ifTrue: [nil] 
		ifFalse: [self rowWith: data last]
]

{ #category : #accessing }
SSWP3ResultSet >> numRows [

	| stream |
	
	stream := results readStream.
	[ stream atEnd or: [ stream peek isDigit ] ] whileFalse: [ stream next ].

	^stream atEnd 
		ifTrue: [ 0 ]
		ifFalse: [ Integer readFrom: stream ]
]

{ #category : #accessing }
SSWP3ResultSet >> query [
	^ query
]

{ #category : #accessing }
SSWP3ResultSet >> query: anObject [
	query := anObject
]

{ #category : #'initialize-release' }
SSWP3ResultSet >> results: rCollection descriptions: dCollection data: dtCollection [

	results := rCollection.
	descriptions := dCollection.
	data := dtCollection
]

{ #category : #enumerating }
SSWP3ResultSet >> rowWith: someData [

	^SSWP3Row newWithColumns: descriptions data: someData query: self query
]

{ #category : #accessing }
SSWP3ResultSet >> size [

	^data size
]
