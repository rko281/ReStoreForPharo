Extension { #name : #Message }

{ #category : #'*Wolphin' }
Message >> value: anObject [

	^self sendTo: anObject
]
