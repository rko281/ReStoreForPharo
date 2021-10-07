Class {
	#name : #SSWDBForwardOnlyReadStream,
	#superclass : #SSWDBReadStream,
	#category : #'SSW ReStore Querying'
}

{ #category : #positioning }
SSWDBForwardOnlyReadStream >> position: anInteger [

	anInteger >= self position ifTrue: [^(anInteger - self position) timesRepeat: [self collectionNext]].

	self resetResultsSet.
	anInteger timesRepeat: [self collectionNext]
]

{ #category : #positioning }
SSWDBForwardOnlyReadStream >> resetResultsSet [

	collection isNil ifFalse: [collection free].
	self reinitialize
]
