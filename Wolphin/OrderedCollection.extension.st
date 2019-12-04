Extension { #name : #OrderedCollection }

{ #category : #'*Wolphin' }
OrderedCollection >> removeAtIndex: anInteger [

	^self removeAt: anInteger
]

{ #category : #'*Wolphin' }
OrderedCollection >> removeFirstIfAbsent: exceptionHandler [
	"Remove and answer the first element of the receiver, but if the
	receiver is empty answer the result of evaluating the <niladicValuable>,
	exceptionHandler."

	self isEmpty ifTrue: [^exceptionHandler value].
	^self removeFirst
]
