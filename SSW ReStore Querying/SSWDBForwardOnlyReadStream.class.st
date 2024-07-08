Class {
	#name : 'SSWDBForwardOnlyReadStream',
	#superclass : 'SSWDBReadStream',
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'evaluating' }
SSWDBForwardOnlyReadStream >> evaluatePostReadActionsFor: aCollection [

	"We can't back-up so if we're at the end free things up"
	self atEnd ifTrue: [self close].

	^super evaluatePostReadActionsFor: aCollection
]

{ #category : 'positioning' }
SSWDBForwardOnlyReadStream >> position: anInteger [

	anInteger >= self position ifTrue: [^(anInteger - self position) timesRepeat: [self collectionNext]].

	self resetResultsSet.
	anInteger timesRepeat: [self collectionNext]
]

{ #category : 'positioning' }
SSWDBForwardOnlyReadStream >> resetResultsSet [

	collection isNil ifFalse: [collection free].
	self reinitialize
]
