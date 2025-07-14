Extension { #name : 'UUID' }

{ #category : '*SSW ReStore ODBC' }
UUID >> asByteArray [

	^uuidData 
]

{ #category : '*SSW ReStore ODBC' }
UUID class >> dbMaxFieldSize [

	^16
]
