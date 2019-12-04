Extension { #name : #Float }

{ #category : #'*SSW ReStore SQL Entities' }
Float class >> writeSQLTypeOn: aStream  using: anSQLDialect [

	aStream nextPutAll: anSQLDialect double
]
