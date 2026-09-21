Extension { #name : 'SSWPostgreSQLDialect' }

{ #category : '*SSW ReStore ODBC' }
SSWPostgreSQLDialect class >> dbmsName [

	^'PostgreSQL'
]

{ #category : '*SSW ReStore ODBC' }
SSWPostgreSQLDialect >> shouldCheckAutoCommit [

	^true
]
