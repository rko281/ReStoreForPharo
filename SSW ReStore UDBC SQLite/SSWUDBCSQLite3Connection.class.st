Class {
	#name : #SSWUDBCSQLite3Connection,
	#superclass : #UDBCSQLite3Connection,
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#category : #'SSW ReStore UDBC SQLite'
}

{ #category : #'connection open/close' }
SSWUDBCSQLite3Connection >> basicClose [

	super close
]

{ #category : #initialization }
SSWUDBCSQLite3Connection >> basicConnect [

	dbHandle isNil ifTrue: [ dbHandle := UDBCSQLite3DatabaseExternalObject new ].

	^self open
]

{ #category : #'public API - introspection' }
SSWUDBCSQLite3Connection >> columnNamesFor: aTableName [
	
	self isOpen
		ifFalse: [ UDBCSQLite3NotOpen signal ]
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
SSWUDBCSQLite3Connection >> dbErrorClass [

	^UDBCSQLite3Error
]

{ #category : #querying }
SSWUDBCSQLite3Connection >> exec: aString [

	^ SSWUDBCSQLite3ResultSet new execute: aString 
		with: #() 
		on: self	
]

{ #category : #querying }
SSWUDBCSQLite3Connection >> executeQuery: anSQLQuery cursorType: aSymbol [

	"Entry point for ad-hoc querying"

	anSQLQuery preExecIn: self.

	^(self newStatement: aSymbol) 
		execQuery: anSQLQuery;
		yourself
]

{ #category : #initialization }
SSWUDBCSQLite3Connection >> initialize [
	
	super initialize.
	statementClass := SSWUDBCSQLite3Statement
]

{ #category : #testing }
SSWUDBCSQLite3Connection >> isConnected [

	^self isOpen
]

{ #category : #querying }
SSWUDBCSQLite3Connection >> newStatement [

	^SSWUDBCSQLite3ResultSet new
		parent: self;
		yourself
]

{ #category : #querying }
SSWUDBCSQLite3Connection >> prepareQuery: anSQLQuery [

	"Entry point for system-generated querying (read, refresh, insert).
	Prepare and return a parameterized statement for the execution of anSQLQuery"

	^(self newStatement
		prepareStatement: (anSQLQuery sqlStringIn: self sqlDialect))
		query: anSQLQuery;
		paramCols: (self columnsForFields: anSQLQuery parameterisedFields);
		yourself 
]

{ #category : #'connection open/close' }
SSWUDBCSQLite3Connection >> prepareToClose [

	"Allow resources to be finalized"
	Smalltalk garbageCollectMost
]

{ #category : #printing }
SSWUDBCSQLite3Connection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $?
]

{ #category : #constants }
SSWUDBCSQLite3Connection >> sqlDialectClass [

	^SSWSQLiteDialect
]

{ #category : #accessing }
SSWUDBCSQLite3Connection >> tables [

	^self tableNames
]
