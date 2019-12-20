Trait {
	#name : #SSWReStoreDBConnection,
	#instVars : [
		'sqlDialect',
		'debugStream',
		'columnDescriptions',
		'hasTxn',
		'queryCount'
	],
	#category : #'SSW ReStore for Pharo'
}

{ #category : #enquiries }
SSWReStoreDBConnection >> _columnsInTable: aDBTable [

	| names columns |
	
	names := self columnNamesFor: aDBTable name.
	names isNil ifTrue: [ ^#() ].

	columns := OrderedCollection new: names size.
	names doWithIndex: 
		[ :name :index | 
		columns add:
			( SSWDBCColAttr new 
					name: name;
					index: index;
					tableName: aDBTable name;
					connection: self; 
					yourself ) ].
				
	^columns
]

{ #category : #transactions }
SSWReStoreDBConnection >> beginRWTxn [

	self beginTxn
]

{ #category : #transactions }
SSWReStoreDBConnection >> beginTxn [

	self beginTransaction.
	self hasTxn: true
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> close [ 

	self 
		prepareToClose;
		basicClose;
		resetTrait
]

{ #category : #accessing }
SSWReStoreDBConnection >> columnDescriptions [
	^ columnDescriptions
]

{ #category : #accessing }
SSWReStoreDBConnection >> columnDescriptions: anObject [
	columnDescriptions := anObject
]

{ #category : #enquiries }
SSWReStoreDBConnection >> columns: aTableName [

	^(self columnNamesFor: aTableName) collect: [ :each | SSWDBCColAttr new name: each]
]

{ #category : #enquiries }
SSWReStoreDBConnection >> columnsForFields: aCollectionOfDBFields [

	^aCollectionOfDBFields collect: [ :field | field columnIn: self]
]

{ #category : #enquiries }
SSWReStoreDBConnection >> columnsInTable: aDBTable [

	^self columnDescriptions at: aDBTable ifAbsentPut: 
		[| columns fieldMap | 
		columns := self _columnsInTable: aDBTable.
		fieldMap := IdentityDictionary new.
		aDBTable allFieldsDo: [ :field | (columns detect: [ :col | col name = field name] ifNone: [nil]) ifNotNil: [ :column | fieldMap at: field put: column]].
		fieldMap]
]

{ #category : #transactions }
SSWReStoreDBConnection >> commitTxn [

	self commitTransaction.
	self hasTxn: false
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> connect [ 

	self basicConnect.
	
	self isConnected ifTrue: 
		[self sqlDialect: (self sqlDialectClass newFor: self).
		self resetTrait]
]

{ #category : #accessing }
SSWReStoreDBConnection >> debugStream [
	^ debugStream
]

{ #category : #accessing }
SSWReStoreDBConnection >> debugStream: anObject [
	debugStream := anObject
]

{ #category : #transactions }
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

{ #category : #querying }
SSWReStoreDBConnection >> exec: aString [

	self logQueryExecution: aString.
	^self execute: aString
]

{ #category : #querying }
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
		exec;
		yourself
]

{ #category : #accessing }
SSWReStoreDBConnection >> forgetTable: aDBTable [

	self columnDescriptions removeKey: aDBTable ifAbsent: []
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> free [ 
	self close
]

{ #category : #transactions }
SSWReStoreDBConnection >> hasTxn [

	^hasTxn ifNil: [ hasTxn := false ]
]

{ #category : #accessing }
SSWReStoreDBConnection >> hasTxn: aBoolean [

	hasTxn := aBoolean
]

{ #category : #querying }
SSWReStoreDBConnection >> incrementQueryCount [

	queryCount ifNotNil: [ queryCount := queryCount + 1 ]
]

{ #category : #testing }
SSWReStoreDBConnection >> isDebug [

	^self debugStream notNil
]

{ #category : #querying }
SSWReStoreDBConnection >> logQueryExecution: aString [

	self debugStream ifNotNil: [ :stream | stream cr; show: aString].
	self incrementQueryCount
]

{ #category : #accessing }
SSWReStoreDBConnection >> maxColumnNameLength [
	^63
]

{ #category : #accessing }
SSWReStoreDBConnection >> maxTableNameLength [
	^63
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> onStartup [ 

	[self close] on: self dbErrorClass do: [ :exc | exc return].
	[self connect] on: self dbErrorClass do: [ :exc | exc return]
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> postConnect [

	self sqlDialect postLoginScript ifNotNil: 
		[ :script | 
		self evaluateAsTxn: [self exec: script. true]]
]

{ #category : #querying }
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

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> prepareToClose [

	"Pre-close actions; users reimplement as necessary"
]

{ #category : #printing }
SSWReStoreDBConnection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $?
]

{ #category : #accessing }
SSWReStoreDBConnection >> queryCount [
	^ queryCount
]

{ #category : #accessing }
SSWReStoreDBConnection >> queryCount: anObject [
	queryCount := anObject
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> reset [

	"Carry out any reset actions necessary after connect or disconnect"
]

{ #category : #querying }
SSWReStoreDBConnection >> resetQueryCount [

	self queryCount: 0

	
]

{ #category : #'connection open/close' }
SSWReStoreDBConnection >> resetTrait [

	self 
		columnDescriptions: IdentityDictionary new;
		reset
]

{ #category : #transactions }
SSWReStoreDBConnection >> rollbackTxn [

	"begin a transaction if one is not active
	(for db refresh purposes it can be useful to arbitarily execut a rollback)"

	self hasTxn ifFalse: [ self beginTxn ].
	self rollbackTransaction.
	self hasTxn: false
]

{ #category : #accessing }
SSWReStoreDBConnection >> sqlDialect [
	^ sqlDialect
]

{ #category : #accessing }
SSWReStoreDBConnection >> sqlDialect: anObject [
	sqlDialect := anObject
]

{ #category : #querying }
SSWReStoreDBConnection >> stopQueryCounting [

	self queryCount: nil

	
]

{ #category : #accessing }
SSWReStoreDBConnection >> willAutoCommit: aBoolean [
]
