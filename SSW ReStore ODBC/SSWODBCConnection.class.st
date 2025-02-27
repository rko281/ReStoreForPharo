Class {
	#name : 'SSWODBCConnection',
	#superclass : 'ODBCConnection',
	#instVars : [
		'sqlDialect',
		'debugStream',
		'allocatedStatementCount',
		'columnDescriptions',
		'queryCount'
	],
	#category : 'SSW ReStore ODBC',
	#package : 'SSW ReStore ODBC'
}

{ #category : 'enquiries' }
SSWODBCConnection >> _columnsInTable: aDBTable [ 

	"Private - Answer the list of columns in the table matching the specified search criteria"

	| i stmt colAttrs maxBoundBufferSize |

	self sqlDialect shouldUseColumnsStatement ifFalse: [^self _columnsInTableViaQuery: aDBTable].

	stmt := ODBCColumnsStatement parent: self.
	stmt
		catalogName: (self sqlDialect catalogNameForTable: aDBTable);
		schemaName: (self sqlDialect schemaNameForTable: aDBTable);
		tableName: aDBTable name;
		columnName: nil.
	i := 0.
	maxBoundBufferSize := self sqlDialect maxColumnBytes.
	colAttrs := stmt results collect: 
					[:each || name |
					i := i + 1.
					name := each atIndex: 4.
					"at: 'column_name'"	"at: 'DATA_TYPE'"	"at: 'LENGTH'"	"at: 'PRECISION'"	"at: 'SCALE'"
					(SSWODBCColAttr new)
						columnNumber: i;
						name: name;
						type: (each atIndex: 5);
						length: (each atIndex: 8);
						precision: (each atIndex: 7);
						scale: (each atIndex: 9);
						field: (aDBTable fieldNamed: name);
						maxBoundBufferSize: maxBoundBufferSize;
						yourself].
	stmt free.
	^colAttrs
]

{ #category : 'enquiries' }
SSWODBCConnection >> _columnsInTableViaQuery: aDBTable [

	"Use a SELECT query to interrogate the column definitions for aDBTable.
	Necessary where information returned via DBColumnsStatement can be inaccurate (sole case seen so far - SQLite3 ODBC driver returns char size rather than buffer size for widestring columns)"

	| query statement |

	query := 
		SSWSQLSelectQuery new 
			table: (SSWDBTable new name: aDBTable name; namespace: aDBTable namespace; yourself); 
			conditions: #(); 
			yourself.

	statement := self exec: (query sqlStringIn: self sqlDialect).

	^statement describeCols: (1 to: statement numColumns)
]

{ #category : 'helpers' }
SSWODBCConnection >> allocStmtHandle: aDBStatement [

	"Keep track of the number of allocated statements"

	| hStmt |

	hStmt := super allocStmtHandle: aDBStatement.

	self allocatedStatementCount: (self allocatedStatementCount + 1).

	^hStmt
]

{ #category : 'accessing' }
SSWODBCConnection >> allocatedStatementCount [
	^allocatedStatementCount
]

{ #category : 'accessing' }
SSWODBCConnection >> allocatedStatementCount: anObject [
	allocatedStatementCount := anObject
]

{ #category : 'transactions' }
SSWODBCConnection >> autoCommitDuring: aBlock [

	| oldValue |

	oldValue := self willAutoCommit.
	self willAutoCommit: true.
	[aBlock value] ensure: [self willAutoCommit: oldValue]
]

{ #category : 'operations' }
SSWODBCConnection >> basicConnect [

	self dsn isNil 
		ifTrue: [self open "uses connectString"]
		ifFalse: [super basicConnect "uses dsn"].

	self isConnected ifTrue: 
		[self sqlDialect: (SSWSQLDialect newFor: self).
		self willAutoCommit: false.
		self reset]
]

{ #category : 'enquiries' }
SSWODBCConnection >> canDescribeParameters [

	^(self getStringInfo: SQL_DESCRIBE_PARAMETER) = 'Y'
]

{ #category : 'accessing' }
SSWODBCConnection >> columnDescriptions [
	^columnDescriptions
]

{ #category : 'accessing' }
SSWODBCConnection >> columnDescriptions: anObject [
	columnDescriptions := anObject
]

{ #category : 'enquiries' }
SSWODBCConnection >> columnsForFields: aCollectionOfDBFields [

	^aCollectionOfDBFields collect: [ :field | field columnIn: self]
]

{ #category : 'enquiries' }
SSWODBCConnection >> columnsInTable: aDBTable [

	^self columnDescriptions at: aDBTable ifAbsentPut: 
		[| columns fieldMap | 
		columns := self _columnsInTable: aDBTable.
		fieldMap := IdentityDictionary new.
		aDBTable allFieldsDo: [ :field | (columns detect: [ :col | col name = field name] ifNone: [nil]) ifNotNil: [ :column | fieldMap at: field put: column]].
		fieldMap]
]

{ #category : 'operations' }
SSWODBCConnection >> createNamespace: aString [

	"Private - Create the given namespace (schema/database) - implementation depends on dialect"

	self autoCommitDuring: [self exec: (self sqlDialect createNamespaceSQLFor: aString)]
]

{ #category : 'exceptions' }
SSWODBCConnection >> dbCheckException: anIntegerRetCode [

	"Overriden to revector to new dbCheckException:from: method, which may mask certain 'errors' "
	
	^self dbCheckException: anIntegerRetCode from: self
]

{ #category : 'exceptions' }
SSWODBCConnection >> dbCheckException: anIntegerRetCode from: anODBCObject [

	"Check anIntegerRetCode as returned to anODBCObject.
	Report an error/notification if appropriate"

	^anIntegerRetCode = SQL_SUCCESS ifFalse: 
		["Signal an error or warning - decide which"
		(anIntegerRetCode = SQL_SUCCESS_WITH_INFO or: [anIntegerRetCode = SQL_NO_DATA])
		ifTrue: 
			[(self sqlDialect ifNil: ["During login - keep quiet" true] ifNotNil: [ :dialect | dialect shouldMaskSuccessWithInfo]) ifFalse:
				[ODBCWarning signalWith: (anODBCObject exceptionDetails: anIntegerRetCode)]]
		ifFalse: 
			[ODBCError signalWith: (anODBCObject exceptionDetails: anIntegerRetCode)]]
]

{ #category : 'accessing' }
SSWODBCConnection >> dbErrorClass [

	^ODBCError
]

{ #category : 'accessing' }
SSWODBCConnection >> debugStream [
	^debugStream
]

{ #category : 'accessing' }
SSWODBCConnection >> debugStream: anObject [
	debugStream := anObject
]

{ #category : 'constants' }
SSWODBCConnection >> defaultCursorType [

	"Overriden to defer to the dialect"

	^self sqlDialect defaultCursorType
]

{ #category : 'constants' }
SSWODBCConnection >> defaultMaxColumnBytes [

	"defaultMaxColumnBytes defines the default maximum size of a column in bytes - this is used to initialize/cap the size of a column's replication buffer.
	
	The default is 128KB (2 raisedTo: 17) which is increased compared to the limit defined in Dolphin's Database Connection (64KB, 2 raisedTo: 16 - see DBField>>initializeForColumn:).
	If a larger size is needed you can set an appropriate value for your application following login by sending maxColumnBytes: to your ReStore's sqlDialect object.
	Bear in mind that wide character strings (if supported) can use > 1 byte per character.
	
	Also bear in mind that this value is used when creating a ByteArray for each unsized column which is replicated.
	If you increase this value then consider specifying a maximum String size in your reStoreDefinition methods to avoid unnecessarily large buffers.

	Also bear in mind that this value can be limited by the ODBC driver. 
	e.g. as of writing SQLite appears to be limited to 65536 bytes, whilst Postgres lets you specify the limit in the Datasource dialog (but the default is only 8190 bytes!!!!)

	Purely anecdotally, a maxColumnBytes of 1MB (2 raisedTo: 20) makes no discernable performance difference compared to the Dolphin default size of 64KB when run over the entire ReStore test suite.

	Very large values really need the use of unbound columns and incremental (paged) put/getData, however this is not yet implemented (and is potentially less performant than bound columns)"

	^"2**17" 131072
]

{ #category : 'operations' }
SSWODBCConnection >> disconnect [

	"Going through a Txn cycle seems to help when disconnecting"
	self rollbackTxn.

	"Occasional error in invalidateAllStmts seen in SQLite - works on retry after a short wait"
	[super disconnect] on: ODBCError do: 
		[ :exc | 
		exc isInvalidTransactionState ifTrue: 
			[(Delay forMilliseconds: 100) wait.
			super disconnect]].

	self reset
]

{ #category : 'operations' }
SSWODBCConnection >> dropNamespace: aString [

	"Private - Drop the given namespace (schema/database) - implementation depends on dialect"

	self autoCommitDuring: [self exec: (self sqlDialect dropNamespaceSQLFor: aString)]
]

{ #category : 'transactions' }
SSWODBCConnection >> evaluateAsTxn: aBlock [

	"Evaluate aBlock within a database transaction (Txn in Dolphin DBConnect parlance).
	aBlock should evaluate to aBoolean indicating the success of its operation.
	If true, the transaction is committed, if false it is rolled back"

	^
		[self beginRWTxn.
		aBlock value
			ifTrue: [self commitTxn. true]
			ifFalse: [self rollbackTxn. false]] on: Error do: [ :exc | self rollbackTxn. exc pass]
]

{ #category : 'exceptions' }
SSWODBCConnection >> executeQuery: anSQLQuery cursorType: aSymbol [

	"Entry point for ad-hoc querying"

	anSQLQuery preExecIn: self.

	^(self newStatement: (aSymbol ifNil: [self defaultCursorType]))
		execQuery: anSQLQuery;
		yourself
]

{ #category : 'helpers' }
SSWODBCConnection >> forgetTable: aDBTable [

	^self columnDescriptions removeKey: aDBTable ifAbsent: []
]

{ #category : 'helpers' }
SSWODBCConnection >> freeStmtHandle: aDBStatement [

	"Keep track of the number of allocated statements"

	super freeStmtHandle: aDBStatement.

	self allocatedStatementCount: (self allocatedStatementCount - 1)
]

{ #category : 'helpers' }
SSWODBCConnection >> getLongInfoString: infoCode [

	"Ignore the SQL_MAX_MESSAGE_LENGTH constant 
	 - SQLKeywords seems to violate this for some ODBC drivers/databases.
	Answer a String containing the value of the receiver's info attribute described by infoCode."

	| bufferLen buffer len |

	bufferLen := self stringEncoder byteSizeForCharacters: 2048	"not SQL_MAX_MESSAGE_LENGTH".
	buffer := ExternalAddress allocate: bufferLen.
	len := SQLSMALLINT new.

	self dbCheckException: 
		(ODBCLibrary default  
			sqlGetInfo: self asParameter
			infoType: infoCode
			infoValuePtr: buffer
			bufferLength: buffer size
			stringLengthPtr: len).

	^buffer copyFrom: 1 to: (len value / 2)
]

{ #category : 'transactions' }
SSWODBCConnection >> hasTxn [

	^transaction notNil
]

{ #category : 'operations' }
SSWODBCConnection >> incrementQueryCount [

	queryCount ifNotNil: [ queryCount := queryCount + 1 ]
]

{ #category : 'testing' }
SSWODBCConnection >> isConnected [

	^handle notNil and: [ handle isNull not ]
]

{ #category : 'testing' }
SSWODBCConnection >> isDebug [

	^self debugStream notNil
]

{ #category : 'operations' }
SSWODBCConnection >> logStatementExec: aStatement [

	debugStream ifNotNil: [aStatement  writeDebugInfoOn: debugStream].
	queryCount ifNotNil: [ queryCount := queryCount + 1 ]
]

{ #category : 'operations' }
SSWODBCConnection >> newParameterizedStatement: aSymbol [

	"We don't make a distinction between parameterized and immediate statements.
	This method isn't used by ReStore but override for completeness"

	^self newStatement: aSymbol
]

{ #category : 'operations' }
SSWODBCConnection >> newStatement [

	"Defer to newStatement"

	^self newStatement: self defaultCursorType
]

{ #category : 'operations' }
SSWODBCConnection >> newStatement: aSymbol [

	"Overriden to use an the appropriate statement class"

	^SSWODBCStatement parent: self cursorType: aSymbol
]

{ #category : 'helpers' }
SSWODBCConnection >> onStartup [

	"Private - Nothing to do here"
]

{ #category : 'operations' }
SSWODBCConnection >> postConnect [

	self sqlDialect onConnected: self
]

{ #category : 'executing' }
SSWODBCConnection >> postExec [

	"Private - Sent immediately following the execution of a statement - carry out the rollback-on-query behavior required by some dialects"

	(transaction isNil and: [self sqlDialect shouldRollbackOnQuery]) ifTrue: [ODBCConnection transact: self action: SQL_ROLLBACK]
]

{ #category : 'executing' }
SSWODBCConnection >> prepareQuery: anSQLQuery [

	"Entry point for system-generated querying (read, refresh, insert).
	Prepare and return a parameterized statement for the execution of anSQLQuery"

	^(self prepare: (anSQLQuery sqlStringIn: self sqlDialect))
		query: anSQLQuery;
		paramCols: (self columnsForFields: anSQLQuery parameterisedFields);
		yourself
]

{ #category : 'helpers' }
SSWODBCConnection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $?
]

{ #category : 'accessing' }
SSWODBCConnection >> queryCount [
	^queryCount
]

{ #category : 'accessing' }
SSWODBCConnection >> queryCount: anObject [
	queryCount := anObject
]

{ #category : 'helpers' }
SSWODBCConnection >> reset [

	self 
		columnDescriptions: IdentityDictionary new;
		allocatedStatementCount: 0
]

{ #category : 'operations' }
SSWODBCConnection >> resetQueryCount [

	self queryCount: 0
]

{ #category : 'transactions' }
SSWODBCConnection >> rollbackTxn [

	"Overriden to begin a transaction if one is not active
	(for db refresh purposes it can be useful to arbitarily execut an ODBC rollback)"

	self hasTxn ifFalse: [self beginTxn].
	super rollbackTxn
]

{ #category : 'testing' }
SSWODBCConnection >> shouldFreeStatementsOnClose [

	"Some dialects slowdown or have a hard limit on the number of allocated statements.
	Attempt to handle this by requiring statements to be freed when closed if the limit has been surpassed"

	^self allocatedStatementCount > self sqlDialect maxAllocatedStatements
]

{ #category : 'accessing' }
SSWODBCConnection >> sqlDialect [

	"sqlDialect stores the SSWSQLDialect of the database to which the receiver connects"

	^sqlDialect
]

{ #category : 'accessing' }
SSWODBCConnection >> sqlDialect: anSSWSQLDialect [

	"sqlDialect stores the SSWSQLDialect of the database to which the receiver connects"

	sqlDialect := anSSWSQLDialect
]

{ #category : 'operations' }
SSWODBCConnection >> stopQueryCounting [

	self queryCount: nil
]

{ #category : 'testing' }
SSWODBCConnection >> supportsScrollableCursors [

	^self supportsScrollableDynamicCursorType or: [self supportsScrollableStaticCursorType]
]

{ #category : 'testing' }
SSWODBCConnection >> supportsScrollableDynamicCursorType [

	^(self getSQLUIntegerInfo: SQL_DYNAMIC_CURSOR_ATTRIBUTES1) allMask: SQL_CA1_ABSOLUTE
]

{ #category : 'testing' }
SSWODBCConnection >> supportsScrollableStaticCursorType [

	^(self getSQLUIntegerInfo: SQL_STATIC_CURSOR_ATTRIBUTES1) allMask: SQL_CA1_ABSOLUTE
]

{ #category : 'accessing' }
SSWODBCConnection >> tables [

	^self tablesInNamespace: nil
]

{ #category : 'enquiries' }
SSWODBCConnection >> tablesInNamespace: aStringOrNil [

	"Answer a collection of all user tables in the namespace named aStringOrNil (nil = default namespace).
	Varies by dialect"

	^self sqlDialect tableNamesInNamespace: aStringOrNil for: self
]

{ #category : 'transactions' }
SSWODBCConnection >> transaction: aDBTxn [ 
	"Overridden to avoid resetting the willAutoCommit status - ReStore never auto-commits (other than during autoCommitDuring: )"

	transaction notNil 
		ifTrue: [self error: self printString , ' already has an active transaction'].
	transaction := aDBTxn
]

{ #category : 'helpers' }
SSWODBCConnection >> upToParameterPlaceholderOn: aStream [

	^aStream upTo: $?
]

{ #category : 'accessing' }
SSWODBCConnection >> willAutoCommit: aBoolean [

	"Overriden to check status prior to changing (dependent on dialect setting)"

	(self sqlDialect shouldCheckAutoCommit and: [self willAutoCommit = aBoolean]) ifFalse: 
		[super willAutoCommit: aBoolean]
]
