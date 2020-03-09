Class {
	#name : #SSWDBForwardOnlyReadStream,
	#superclass : #SSWDBReadStream,
	#category : #'SSW ReStore Querying'
}

{ #category : #positioning }
SSWDBForwardOnlyReadStream >> position: anInteger [

	anInteger >= self position ifTrue: [^(anInteger - self position) timesRepeat: [self collectionNext]].

	self reinitialize.
	anInteger timesRepeat: [self collectionNext]
]

{ #category : #positioning }
SSWDBForwardOnlyReadStream >> resetResultsSet [

	self reinitialize
]
