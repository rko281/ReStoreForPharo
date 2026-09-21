Extension { #name : 'SSWMySQLDialect' }

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect class >> _isCompatibleWithConnection: aDBConnection [

	"Private - To allow MariaDB subclass to access default implementation"

	^super isCompatibleWithConnection: aDBConnection
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect >> catalogNameForTable: aDBTable [

	^aDBTable namespace
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect class >> dbmsName [

	^'MySQL'
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect class >> isCompatibleWithConnection: aDBConnection [

	"For ODBC we need to query version() to differentiate between MySQL and MariaDB:
	 - MySQL ODBC driver always reports 'MySQL' for connection's dbmsName but when connected to MariaDB has 'MariaDB' as part of version string
	 - MariaDB ODBC driver alwasy reports actual database name for both MySQL and MariaDB"

	^(super isCompatibleWithConnection: aDBConnection) and: [('*MariaDB*' match: aDBConnection dbmsVersion) not]
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect >> schemaNameForTable: aDBTable [

	^nil
]

{ #category : '*SSW ReStore ODBC' }
SSWMySQLDialect >> tableNamesInNamespace: aString for: aDBConnection [

	^aDBConnection tables: aString owners: nil tables: nil types: '''TABLE'''
]
