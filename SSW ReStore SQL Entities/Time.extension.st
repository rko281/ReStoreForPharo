Extension { #name : 'Time' }

{ #category : '*SSW ReStore SQL Entities' }
Time class >> writeSQLTypeOn: aStream using: anSQLDialect [

	aStream nextPutAll: anSQLDialect time
]
