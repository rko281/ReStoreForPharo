Extension { #name : #SSWSQLConditionCollection }

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLConditionCollection >> and: aBlock [

	^self & aBlock value
]

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLConditionCollection >> or: aBlock [

	^self | aBlock value
]
