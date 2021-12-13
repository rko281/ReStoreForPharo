Extension { #name : #SSWSQLParameterField }

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLParameterField >> asParameterColumn: anInteger for: aStatement [

	^(aStatement describeParam: anInteger) ifNil: [self value asParameterColumn]
]
