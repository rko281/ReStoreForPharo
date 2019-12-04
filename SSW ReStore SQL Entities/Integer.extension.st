Extension { #name : #Integer }

{ #category : #'*SSW ReStore SQL Entities' }
Integer class >> writeSQLTypeOn: aStream  using: anSQLDialect [

	"Use INT - long integer"
	
	aStream nextPutAll: anSQLDialect integer
]
