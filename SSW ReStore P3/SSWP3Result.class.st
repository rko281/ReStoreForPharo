Class {
	#name : #SSWP3Result,
	#superclass : #P3Result,
	#instVars : [
		'query'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #'initialize-release' }
SSWP3Result >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : #'initialize-release' }
SSWP3Result >> closeAfter: aBlock [

	^aBlock value: self
]

{ #category : #enumerating }
SSWP3Result >> do: aBlock [

	data do: [ :vals | aBlock value: (SSWP3Row new columns: descriptions; data: vals; createFieldMapFrom: self query; yourself)]
]

{ #category : #enumerating }
SSWP3Result >> first [

	^data isEmpty ifTrue: [nil] ifFalse: [SSWP3Row new columns: descriptions; data: data first; createFieldMapFrom: self query; yourself]
]

{ #category : #accessing }
SSWP3Result >> last [

	^data isEmpty ifTrue: [nil] ifFalse: [SSWP3Row new columns: descriptions; data: data last; createFieldMapFrom: self query; yourself]
]

{ #category : #accessing }
SSWP3Result >> numRows [

	| stream |
	
	stream := results readStream.
	[ stream atEnd or: [ stream peek isDigit ] ] whileFalse: [ stream next ].

	^stream atEnd 
		ifTrue: [ 0 ]
		ifFalse: [ Integer readFrom: stream ]
]

{ #category : #accessing }
SSWP3Result >> query [
	^ query
]

{ #category : #accessing }
SSWP3Result >> query: anObject [
	query := anObject
]

{ #category : #accessing }
SSWP3Result >> results [

	^self
]

{ #category : #'initialize-release' }
SSWP3Result >> results: rCollection descriptions: dCollection data: dtCollection [

	results := rCollection.
	descriptions := dCollection.
	data := dtCollection
]

{ #category : #accessing }
SSWP3Result >> rowsAffected [

	^self closeAfter: [ :stmt | stmt numRows ]
]

{ #category : #accessing }
SSWP3Result >> size [

	^data size
]
