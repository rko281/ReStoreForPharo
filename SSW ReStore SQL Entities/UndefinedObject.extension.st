Extension { #name : 'UndefinedObject' }

{ #category : '*SSW ReStore SQL Entities' }
UndefinedObject >> isSQLNull [

	^true
]

{ #category : '*SSW ReStore SQL Entities' }
UndefinedObject >> writeSQLOn: aStream [

	aStream nextPutAll: 'NULL'
]

{ #category : '*SSW ReStore SQL Entities' }
UndefinedObject >> writeSQLOn: aStream forCondition: aSQLCondition [

	"Do not parameterize - NULL not allowed as parameterized condition value in some DBs"
	self writeSQLOn: aStream
]
