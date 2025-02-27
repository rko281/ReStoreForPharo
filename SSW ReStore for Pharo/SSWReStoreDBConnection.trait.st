Trait {
	#name : 'SSWReStoreDBConnection',
	#instVars : [
		'sqlDialect',
		'debugStream',
		'columnDescriptions',
		'hasTxn',
		'queryCount'
	],
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'enquiries' }
SSWReStoreDBConnection >> _columnsInTable: aDBTable [

	| names columns |
	
	names := self columnNamesForTable: aDBTable.
	names isNil ifTrue: [ ^#() ].

	columns := OrderedCollection new: names size.
	names doWithIndex: 
		[ :name :index | 
		columns add:
			( SSWDBCColAttr new 
					name: name;
					index: index;
					table: aDBTable;
					field: (aDBTable fieldNamed: name);
					yourself ) ].
				
	^columns
]

{ #category : 'transactions' }
SSWReStoreDBConnection >> beginRWTxn [

	self beginTxn
]

{ #category : 'transactions' }
SSWReStoreDBConnection >> beginTxn [

	self beginTransaction.
	self hasTxn: true
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> close [ 

	self 
		prepareToClose;
		basicClose;
		resetTrait
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> columnDescriptions [
	^ columnDescriptions
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> columnDescriptions: anObject [
	columnDescriptions := anObject
]

{ #category : 'enquiries' }
SSWReStoreDBConnection >> columns: aTableName [

	^(self columnNamesFor: aTableName) collect: [ :each | SSWDBCColAttr new name: each]
]

{ #category : 'enquiries' }
SSWReStoreDBConnection >> columnsForFields: aCollectionOfDBFields [

	^aCollectionOfDBFields collect: [ :field | field columnIn: self]
]

{ #category : 'enquiries' }
SSWReStoreDBConnection >> columnsInTable: aDBTable [

	^self columnDescriptions at: aDBTable ifAbsentPut: 
		[| columns fieldMap | 
		columns := self _columnsInTable: aDBTable.
		fieldMap := IdentityDictionary new.
		aDBTable allFieldsDo: [ :field | (columns detect: [ :col | col name = field name] ifNone: [nil]) ifNotNil: [ :column | fieldMap at: field put: column]].
		fieldMap]
]

{ #category : 'transactions' }
SSWReStoreDBConnection >> commitTxn [

	self commitTransaction.
	self hasTxn: false
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> connect [ 

	self basicConnect.
	
	self isConnected ifTrue: 
		[self sqlDialect: (self sqlDialectClass newFor: self).
		self resetTrait]
]

{ #category : 'db maintenance' }
SSWReStoreDBConnection >> createNamespace: aString [

	self execute: 'CREATE SCHEMA ', (self sqlDialect asIdentifier: aString)
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> debugStream [
	^ debugStream
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> debugStream: anObject [
	debugStream := anObject
]

{ #category : 'constants' }
SSWReStoreDBConnection >> defaultMaxColumnBytes [

	"Comment taken from Dolphin implementation; method is included here since it also impacts on the assumed size of unsized Strings:
	
	
	defaultMaxColumnBytes defines the default maximum size of a column in bytes - this is used to initialize/cap the size of a column's replication buffer.
	
	The default is 128KB (2 raisedTo: 17) which is increased compared to the limit defined in Dolphin's Database Connection (64KB, 2 raisedTo: 16 - see DBField>>initializeForColumn:).
	If a larger size is needed you can set an appropriate value for your application following login by sending maxColumnBytes: to your ReStore's sqlDialect object.
	Bear in mind that wide character strings (if supported) can use > 1 byte per character.
	
	Also bear in mind that this value is used when creating a ByteArray for each unsized column which is replicated.
	If you increase this value then consider specifying a maximum String size in your reStoreDefinition methods to avoid unnecessarily large buffers.

	Also bear in mind that this value can be limited by the ODBC driver. 
	e.g. as of writing SQLite appears to be limited to 65536 bytes, whilst Postgres lets you specify the limit in the Datasource dialog (but the default is only 8190 bytes!!)

	Purely anecdotally, a maxColumnBytes of 1MB (2 raisedTo: 20) makes no discernable performance difference compared to the Dolphin default size of 64KB when run over the entire ReStore test suite.

	Very large values really need the use of unbound columns and incremental (paged) put/getData, however this is not yet implemented (and is potentially less performant than bound columns)"

	^"(2**17)" 131072
]

{ #category : 'db maintenance' }
SSWReStoreDBConnection >> dropNamespace: aString [

	self execute: 'DROP SCHEMA ', (self sqlDialect asIdentifier: aString)
]

{ #category : 'transactions' }
SSWReStoreDBConnection >> evaluateAsTxn: aBlock [

	"Evaluate aBlock within a database transaction (Txn in Dolphin DBConnect parlance).
	aBlock should evaluate to aBoolean indicating the success of its operation.
	If true, the transaction is committed, if false it is rolled back"

	^
		[self beginRWTxn.
		aBlock value
			ifTrue: [self commitTxn. true]
			ifFalse: [self rollbackTxn. false]] on: Error do: [ :exc | self rollbackTxn. exc pass]
]

{ #category : 'querying' }
SSWReStoreDBConnection >> exec: aString [

	self logQueryExecution: aString.
	^self execute: aString
]

{ #category : 'querying' }
SSWReStoreDBConnection >> executeQuery: anSQLQuery cursorType: aSymbol [

	"Entry point for ad-hoc querying"

	| stream values statement |
		
	anSQLQuery preExecIn: self.

	stream := SSWSQLWriteStream newIn: self sqlDialect.
	anSQLQuery writeSQLOn: stream.
	values := stream parameterizedValues collect: [ :each | each reStoreValue].
	statement := self prepare: stream contents.

	^statement 
		setQuery: anSQLQuery;
		values: values;
		cursorType: aSymbol;
		exec;
		yourself
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> forgetTable: aDBTable [

	self columnDescriptions removeKey: aDBTable ifAbsent: []
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> free [ 
	self close
]

{ #category : 'transactions' }
SSWReStoreDBConnection >> hasTxn [

	^hasTxn ifNil: [ hasTxn := false ]
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> hasTxn: aBoolean [

	hasTxn := aBoolean
]

{ #category : 'querying' }
SSWReStoreDBConnection >> incrementQueryCount [

	queryCount ifNotNil: [ queryCount := queryCount + 1 ]
]

{ #category : 'testing' }
SSWReStoreDBConnection >> isDebug [

	^self debugStream notNil
]

{ #category : 'querying' }
SSWReStoreDBConnection >> logQueryExecution: aString [

	self debugStream ifNotNil: [ :stream | stream nextPutAll: aString; nextPut: $;; cr].
	self incrementQueryCount
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> maxColumnNameLength [
	^63
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> maxTableNameLength [
	^63
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> onStartup [ 

	[self close] on: self dbErrorClass do: [ :exc | exc return].
	[self connect] on: self dbErrorClass do: [ :exc | exc return]
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> postConnect [

	self sqlDialect onConnected: self
]

{ #category : 'querying' }
SSWReStoreDBConnection >> prepareQuery: anSQLQuery [

	"Entry point for system-generated querying (read, refresh, insert).
	Prepare and return a parameterized statement for the execution of anSQLQuery"

	| stream |
		
	anSQLQuery preExecIn: self.

	stream := SSWSQLWriteStream newIn: self sqlDialect.
	anSQLQuery writeSQLOn: stream.

	^(self prepare: stream contents)
		setQuery: anSQLQuery;
		parametersCount: stream parameterizedValues size;
		yourself
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> prepareToClose [

	"Pre-close actions; users reimplement as necessary"
]

{ #category : 'printing' }
SSWReStoreDBConnection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $?
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> queryCount [
	^ queryCount
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> queryCount: anObject [
	queryCount := anObject
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> reset [

	"Carry out any reset actions necessary after connect or disconnect"
]

{ #category : 'querying' }
SSWReStoreDBConnection >> resetQueryCount [

	self queryCount: 0

	
]

{ #category : 'connection open/close' }
SSWReStoreDBConnection >> resetTrait [

	self 
		columnDescriptions: IdentityDictionary new;
		reset
]

{ #category : 'transactions' }
SSWReStoreDBConnection >> rollbackTxn [

	"begin a transaction if one is not active
	(for db refresh purposes it can be useful to arbitarily execut a rollback)"

	self hasTxn ifFalse: [ self beginTxn ].
	self rollbackTransaction.
	self hasTxn: false
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> sqlDialect [
	^ sqlDialect
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> sqlDialect: anObject [
	sqlDialect := anObject
]

{ #category : 'querying' }
SSWReStoreDBConnection >> stopQueryCounting [

	self queryCount: nil

	
]

{ #category : 'testing' }
SSWReStoreDBConnection >> supportsScrollableCursors [

	^false
]

{ #category : 'enquiries' }
SSWReStoreDBConnection >> tables [

	^self tablesInNamespace: self sqlDialect standardNamespace
]

{ #category : 'accessing' }
SSWReStoreDBConnection >> willAutoCommit: aBoolean [
]
