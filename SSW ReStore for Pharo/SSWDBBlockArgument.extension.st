Extension { #name : 'SSWDBBlockArgument' }

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> and: aBlock [

	"Only sent in case of an implicit '= true' expression (or an error)"
	
	^self implicitEqualsTrue and: aBlock
	
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> ifNil: aBlock [
	
	^self doesNotUnderstand: (Message selector: #ifNil: argument: aBlock value)
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> ifNotNil: aBlock [
	
	^self doesNotUnderstand: (Message selector: #ifNotNil: argument: aBlock value)
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> isNil [ 
	^self = nil
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> isString [

	^false
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> notNil [ 
	^self ~= nil
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> or: aBlock [

	"Only sent in case of an implicit '= true' expression (or an error)"
	
	^self implicitEqualsTrue or: aBlock
	
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> postProcessDNU: anObject [

	^self preProcessNextMessageFor: anObject in: thisContext sender sender
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> preProcessNextMessageFor: anObject in: aStackFrame [

	"Check if the next message needs special handling due to anObject (block evaluator) being an argument rather than the receiver.
	Where this is the case reverse the receiver and argument on the stack so this object receives the message.
	A local implementation of the message then handles the reversed receiver and arguments"

	| stackFrame sender node nextMessage rcvr |

	stackFrame := aStackFrame.
	[node := [stackFrame method sourceNodeForPC: stackFrame sswNeighborPCWithCorrectMapping] on: Error do: [ :exc | exc return: nil].
	(node notNil and: [node isMessage ]) or: [(sender := stackFrame sender) isNil or: [ sender receiver == self parser ] ]] whileFalse: [stackFrame := sender ].
	
	(node notNil and: [ node isMessage ]) ifFalse: [^anObject ].

	nextMessage := node selector.
	(nextMessage = #match: or: [nextMessage = #includes: and: [(anObject isKindOf: SSWDBCollectionBlockReceiver) not]]) ifFalse: [^anObject].
	
	rcvr := stackFrame pop.
	stackFrame push: anObject.
	^rcvr
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> simulateMethod: aCompiledMethod withArguments: anArray [

	^aCompiledMethod valueWithReceiver: self arguments: anArray
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockArgument >> stackFrameDetect: aBlock [

	| frame |

	"Skip this frame and its sender"
	frame := thisContext sender sender. 

	[(aBlock value: frame) or: [(frame := frame sender) isNil]] whileFalse.

	^frame
]
