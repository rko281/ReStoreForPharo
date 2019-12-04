Extension { #name : #Number }

{ #category : #'*SSW ReStore SQL Entities' }
Number class >> writeSQLTypeOn: aStream  using: anSQLDialect [

	"Default to single float"
	
	aStream nextPutAll: anSQLDialect float
]
