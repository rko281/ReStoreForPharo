Extension { #name : #Process }

{ #category : #'*SSW ReStore for Pharo' }
Process >> isExpectedToResumePromptly [

	^self isActiveProcess or: [ self suspendingList notNil ]
]

{ #category : #'*SSW ReStore for Pharo' }
Process >> isInIDECallStack [

	"placeholder for now"

	^false
]
