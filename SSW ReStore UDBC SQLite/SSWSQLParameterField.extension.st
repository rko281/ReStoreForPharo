Extension { #name : #SSWSQLParameterField }

{ #category : #'*SSW ReStore UDBC SQLite' }
SSWSQLParameterField >> asParameterColumn: anInteger for: aStatement [

	^(aStatement describeParam: anInteger) ifNil: [self value asParameterColumn]
]
