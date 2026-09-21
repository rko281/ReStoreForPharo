Extension { #name : 'SSWSQLDialect' }

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> canDescribeParameters [

	"Does this dialect support the SQLDescribeParam function?"

	^true
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> catalogNameForTable: aDBTable [

	^nil
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> createNamespaceSQLFor: aString [

	^'CREATE SCHEMA ', (self asIdentifier: aString)
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> cursorType [

	"Return the Symbol-ic name of the ODBC cursor type that will be used when creating statements. 
	See ODBCAbstractStatement>>cursorType for further details"

	^#forwardOnly
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect class >> dbmsName [

	"Return the name of the database whose dialect is represented by the receiver.
	Should correlate with the result of DBConnection>>dbmsName (ignoring case)"

	^self subclassResponsibility
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect class >> dbmsVersion [

	"Return the version of the database whose dialect is represented by the receiver.
	Should correlate with the result of DBConnection>>dbmsVersion (ignoring case).

	From MS ODBC docs: '
		The version is of the form ##.##.####, where the first two digits are the major version, the next two digits are the minor version, and the last four digits are the release version. 
		The driver must render the DBMS product version in this form but can also append the DBMS product-specific version. For example, '04.01.0000 Rdb 4.1'.

	For convenience this value may be a pattern - dialects can handle subtle differences with conditionals (referring to their connection for the version)"

	^'*'
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> dropNamespaceSQLFor: aString [

	^'DROP SCHEMA ', (self asIdentifier: aString)
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect class >> isCompatibleWithConnection: aDBConnection [

	"Default implementation uses name and version.
	Subclasses with more sophisticated requirements may override"

	^(self dbmsName sameAs: aDBConnection dbmsName) and: [self dbmsVersion match: aDBConnection dbmsVersion]
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> schemaNameForTable: aDBTable [

	^aDBTable namespace
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> shouldCheckAutoCommit [

	"Return whether the ODBCConnection should check the status of autoCommit prior to attempting a change"

	^false
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> shouldMaskSuccessWithInfo [

	"Some ODBC databases/drivers send many SQLSuccessWithInfo results.
	shouldMaskSuccessWithInfo determines whether these go unreported (true, standard behavior for most dbs) or are reported via a ODBCWarning exception (false)"

	^true
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> shouldRollbackOnQuery [

	"Should the ODBC connection rollbackTxn following a query outside a Txn?"

	^false
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> shouldUseColumnsStatement [

	"Return whether this dialect should use ODBCColumnsStatement to interrogate the details of a table's columns (true, default) or a SELECT * query (false).
	
	Here primarily to satisfy a shortcoming in SQLite ODBC driver where ODBCColumnsStatement returns the character length for wide string columns, rather than the buffer length.
	Column details returned from a SELECT * query report the buffer length correctly"

	^true
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect class >> subclassFor: aDBConnection [

	"Return the correct subclass of the receiver to use for the given DBConnection"

	"Sort to prefer subclasses with specific version number over non version-specific subclasses"
	^(self allSubclasses asSortedCollection: [ :c1 :c2 | c1 dbmsVersion size >= c2 dbmsVersion size]) detect: [ :each | each isNative not and: [each isCompatibleWithConnection: aDBConnection]] ifNone: ["Fallback" self]
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLDialect >> tableNamesInNamespace: aStringOrNil for: anODBCConnection [

	^anODBCConnection tables: nil owners: (aStringOrNil ifNil: [self standardNamespace]) tables: nil types: '''TABLE'''
]
