Class {
	#name : #SSWSQLite3Connection,
	#superclass : #SQLite3Connection,
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#category : #'SSW ReStore SQLite3'
}

{ #category : #'connection open/close' }
SSWSQLite3Connection >> basicClose [

	super close
]

{ #category : #initialization }
SSWSQLite3Connection >> basicConnect [

	dbHandle isNil ifTrue: [ dbHandle := SQLite3DatabaseExternalObject new ].

	^self open
]

{ #category : #'public API - introspection' }
SSWSQLite3Connection >> columnNamesFor: aTableName [
	
	self isOpen
		ifFalse: [ SQLite3NotOpen signal ]
		ifTrue: [ 
			| s tableExists |
			s := self prepare: 'select count(*) from sqlite_master where type = "table" and tbl_name = ?'.
			s at: 1 putString: aTableName.
	  		s basicExecute: [ :row | tableExists := ((row integerAt: 0) = 1) ].
	  		s finalize.
			tableExists ifTrue: [ 
				| columns |
				columns := OrderedCollection new.
				s := self prepare: 'pragma table_info(', (self sqlDialect asIdentifier: aTableName), ')'.
				s basicExecute: [ :row | columns add: (row stringAt: 1) ].
				s finalize.
				^ columns ].
			^ nil ]
		
]

{ #category : #constants }
SSWSQLite3Connection >> dbErrorClass [

	^SQLite3AbstractError
]

{ #category : #querying }
SSWSQLite3Connection >> exec: aString [

	^ SSWSQLite3ResultSet new execute: aString 
		with: #() 
		on: self	
]

{ #category : #querying }
SSWSQLite3Connection >> executeQuery: anSQLQuery cursorType: aSymbol [

	"Entry point for ad-hoc querying"

	anSQLQuery preExecIn: self.

	^(self newStatement: aSymbol) 
		execQuery: anSQLQuery;
		yourself
]

{ #category : #initialization }
SSWSQLite3Connection >> initialize [
	
	super initialize.
	statementClass := SSWSQLite3Statement
]

{ #category : #testing }
SSWSQLite3Connection >> isConnected [

	^self isOpen
]

{ #category : #querying }
SSWSQLite3Connection >> newStatement [

	^SSWSQLite3ResultSet new
		parent: self;
		yourself
]

{ #category : #querying }
SSWSQLite3Connection >> prepareQuery: anSQLQuery [

	"Entry point for system-generated querying (read, refresh, insert).
	Prepare and return a parameterized statement for the execution of anSQLQuery"

	^(self newStatement
		prepareStatement: (anSQLQuery sqlStringIn: self sqlDialect))
		query: anSQLQuery;
		paramCols: (self columnsForFields: anSQLQuery parameterisedFields);
		yourself 
]

{ #category : #'connection open/close' }
SSWSQLite3Connection >> prepareToClose [

	"Allow resources to be finalized"
	Smalltalk garbageCollectMost
]

{ #category : #printing }
SSWSQLite3Connection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $?
]

{ #category : #constants }
SSWSQLite3Connection >> sqlDialectClass [

	^SSWSQLiteDialect
]

{ #category : #accessing }
SSWSQLite3Connection >> tables [

	^self tableNames
]
