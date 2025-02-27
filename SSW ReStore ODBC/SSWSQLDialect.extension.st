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
SSWSQLDialect >> dropNamespaceSQLFor: aString [

	^'DROP SCHEMA ', (self asIdentifier: aString)
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
SSWSQLDialect >> tableNamesInNamespace: aStringOrNil for: anODBCConnection [

	^anODBCConnection tables: nil owners: (aStringOrNil ifNil: [self standardNamespace]) tables: nil types: '''TABLE'''
]
