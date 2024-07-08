Extension { #name : 'Time' }

{ #category : '*SSW ReStore SQL Entities' }
Time >> asSQLStringIn: aSQLDialect [

	^aSQLDialect timeStringFor: self
]

{ #category : '*SSW ReStore SQL Entities' }
Time class >> writeSQLTypeOn: aStream using: anSQLDialect [

	aStream nextPutAll: anSQLDialect time
]
