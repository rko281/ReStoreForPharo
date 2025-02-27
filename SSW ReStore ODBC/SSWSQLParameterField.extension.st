Extension { #name : 'SSWSQLParameterField' }

{ #category : '*SSW ReStore ODBC' }
SSWSQLParameterField >> asParameterColumn: anInteger for: aStatement [

	^(aStatement describeParam: anInteger) ifNil: [self value asParameterColumn]
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLParameterField class >> dbMaxFieldSize [

	^nil
]
