Extension { #name : 'Metaclass' }

{ #category : '*SSW ReStore SQL Entities' }
Metaclass class >> writeSQLTypeOn: aStream using: anSQLDialect [

	"Classes are stored as their name.
	Use a VARCHAR at 128 characters"
	
	(String maxSize: 128) writeSQLTypeOn: aStream using: anSQLDialect
]
