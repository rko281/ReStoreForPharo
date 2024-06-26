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

	"Check if the next message needs special handling; usually this also results in it being skiped"

	| sender node |

	sender := thisContext sender sender.
	node := [sender method sourceNodeForPC: sender sswNeighborPCWithCorrectMapping] on: Error do: [ :exc | exc return: nil].
	(node notNil and: [node isMessage]) ifFalse: [^anObject ].

	"Collection>>includes: -> self>>includedIn:"
	( node selector = #includes: and: [(anObject isKindOf: SSWDBCollectionBlockReceiver) not ]) ifTrue: 
		[ sender pc: sender sswFollowingPc.
		  ^sender at: sender stackPtr put: (anObject includedIn: (sender at: sender stackPtr)) ].

	"String>>match: -> self>>matches:"
	node selector = #match: ifTrue: 
		[ sender pc: sender sswFollowingPc.
		  ^sender at: sender stackPtr put: (anObject matches: (sender at: sender stackPtr)) ].

	^anObject
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
