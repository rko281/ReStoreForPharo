Extension { #name : #SSWDBBlockArgument }

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockArgument >> isNil [ 
	^self = nil
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockArgument >> isString [

	^false
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockArgument >> notNil [ 
	^self ~= nil
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockArgument >> postProcessDNU: anObject [

	"Check if the next message needs special handling; usually this also results in it being skiped"

	| sender node |

	sender := thisContext sender sender.
	node := sender method sourceNodeForPC: sender neighborPCWithCorrectMapping.
	node isMessage ifFalse: [^anObject ].

	"Collection>>includes: -> self>>includedIn:"
	( node selector = #includes: and: [(anObject isKindOf: SSWDBCollectionBlockReceiver) not ]) ifTrue: 
		[ sender pc: sender followingPc.
		  ^anObject includedIn: (sender at: sender stackPtr) ].

	"String>>match: -> self>>matches:"
	node selector = #match: ifTrue: 
		[ sender pc: sender followingPc.
		  ^anObject matches: (sender at: sender stackPtr) ].

	^anObject
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockArgument >> simulateMessageSend: aMessage [

	| method |

	method := self currentClass lookupSelector: aMessage selector.
	method isNil ifTrue: [self parseError: (self currentClass name, ' does not implement #', aMessage selector)].
	^method valueWithReceiver: self arguments: aMessage arguments
]
