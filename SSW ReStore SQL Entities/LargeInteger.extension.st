Extension { #name : 'LargeInteger' }

{ #category : '*SSW ReStore SQL Entities' }
LargeInteger class >> writeSQLTypeOn: aStream  using: anSQLDialect [

	"Map LargeInteger to (typically) BIGINT"
	
	aStream nextPutAll: anSQLDialect largeInteger
]
