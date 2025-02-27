Extension { #name : 'Date' }

{ #category : '*SSW ReStore SQL Entities' }
Date class >> writeSQLTypeOn: aStream using: anSQLDialect [

	^aStream nextPutAll: anSQLDialect date
]
