Extension { #name : 'SSWMySQLDialect' }

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect >> catalogNameForTable: aDBTable [

	^aDBTable namespace
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect >> schemaNameForTable: aDBTable [

	^nil
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect >> tableNamesInNamespace: aString for: aDBConnection [

	^aDBConnection tables: aString owners: nil tables: nil types: '''TABLE'''
]
