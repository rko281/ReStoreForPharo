Extension { #name : 'FinalizationRegistry' }

{ #category : '*SSW ReStore ODBC' }
FinalizationRegistry >> do: aBlock [

	^ self keys do: aBlock
]

{ #category : '*SSW ReStore ODBC' }
FinalizationRegistry >> ifNotEmpty: aBlock [

	^self isEmpty ifFalse: [ aBlock value ]
]
