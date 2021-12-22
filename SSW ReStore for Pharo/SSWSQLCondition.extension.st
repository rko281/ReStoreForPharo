Extension { #name : #SSWSQLCondition }

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLCondition >> and: aBlock [

	^self & (aBlock valueWithArguments: #())
]

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLCondition >> or: aBlock [

	^self | (aBlock valueWithArguments: #())
]
