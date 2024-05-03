Extension { #name : 'UUID' }

{ #category : '*SSW ReStore for Pharo' }
UUID class >> instanceFromDBValue: aValue in: anSSWReStore [

	^aValue isCollection 
		ifTrue: [ self new uuidData: aValue asByteArray ]
		ifFalse: [ aValue ]
]

{ #category : '*SSW ReStore for Pharo' }
UUID class >> isPersistentBaseClass [

	^true
]

{ #category : '*SSW ReStore for Pharo' }
UUID class >> reStoreNewUnique [

	^self new
]

{ #category : '*SSW ReStore for Pharo' }
UUID class >> writeSQLTypeOn: aStream using: aSQLDialect [

	aStream nextPutAll: aSQLDialect uuid
]
