Class {
	#name : #SSWSQLite3Connection,
	#superclass : #SQLite3Connection,
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#pools : [
		'SQLite3Constants'
	],
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

{ #category : #'as yet unclassified' }
SSWSQLite3Connection >> columnNamesForTable: aDBTable [
	
	self isOpen
		ifFalse: [ SQLite3NotOpen signal ]
		ifTrue: [ 
			| s tableExists |
			s := self prepare: 'select count(*) from ', (self masterTableForNamespace: aDBTable namespace), ' where type = "table" and tbl_name = ?'.
			s at: 1 putString: aDBTable name.
	  		s basicExecute: [ :row | tableExists := ((row integerAt: 0) = 1) ].
	  		s finalize.
			tableExists ifTrue: [ 
				| columns |
				columns := OrderedCollection new.
				s := self prepare: 'pragma table_info(', (self sqlDialect asIdentifier: aDBTable name), ')'.
				s basicExecute: [ :row | columns add: (row stringAt: 1) ].
				s finalize.
				^ columns ].
			^ nil ]
		
]

{ #category : #'db maintenance' }
SSWSQLite3Connection >> createNamespace: aString [

	"Since there is no filename given, map this to creating a temporary attached database"

	^self execute: 'ATTACH DATABASE '''' AS ', (self sqlDialect asIdentifier: aString)
]

{ #category : #constants }
SSWSQLite3Connection >> dbErrorClass [

	^SQLite3AbstractError
]

{ #category : #enquiries }
SSWSQLite3Connection >> declaredColumnTypesForTable: aDBTable [
	
	self isOpen
		ifFalse: [ SQLite3NotOpen signal ]
		ifTrue: [ 
			| s tableExists |
			s := self prepare: 'select count(*) from ', (self masterTableForNamespace: aDBTable namespace), ' where type = "table" and tbl_name = ?'.
			s at: 1 putString: aDBTable name.
	  		s basicExecute: [ :row | tableExists := ((row integerAt: 0) = 1) ].
	  		s finalize.
			tableExists ifTrue: [ 
				| columns |
				columns := OrderedCollection new.
				s := self prepare: 'pragma table_info(', aDBTable name, ')'.
				s basicExecute: [ :row | columns add: (row stringAt: 2) ].
				s finalize.
				^ columns ].
			^ nil ]
		
]

{ #category : #'db maintenance' }
SSWSQLite3Connection >> dropNamespace: aString [

	^self execute: 'DETACH DATABASE ', (self sqlDialect asIdentifier: aString)
]

{ #category : #querying }
SSWSQLite3Connection >> execute: aString [

	^(self prepare: aString) execute
]

{ #category : #'public API - operating' }
SSWSQLite3Connection >> finalize: aStatementHandle [

	^dbHandle isNil 
		ifTrue: [ library apiFinalize: aStatementHandle ]
		ifFalse: [ super finalize: aStatementHandle ]
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

{ #category : #enquiries }
SSWSQLite3Connection >> masterTableForNamespace: aString [

	^(aString isNil or: [aString = self sqlDialect standardNamespace])
		ifTrue: [ 'sqlite_master' ]
		ifFalse: [ aString, '.sqlite_master' ]
]

{ #category : #'connection open/close' }
SSWSQLite3Connection >> open [

	"Override to enable URI naming if specified by the dbFilename"
	
	(dbFilename beginsWith: 'file:') ifFalse: [ ^super open ].

	library 
		open: dbFilename 
		withFlags: (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_URI) 
		via: dbHandle.
		
	isOpen := true
]

{ #category : #'connection open/close' }
SSWSQLite3Connection >> prepareToClose [

	"Allow resources to be finalized"
	SmalltalkImage current garbageCollectMost
]

{ #category : #constants }
SSWSQLite3Connection >> sqlDialectClass [

	^SSWSQLiteNativeDialect
]

{ #category : #enquiries }
SSWSQLite3Connection >> tablesInNamespace: aString [

	| tables s |
	
	self isOpen
		ifFalse: [ SQLite3NotOpen signal ]
		ifTrue: [ 
			tables := OrderedCollection new.
			s := self prepare: 'select tbl_name from ', (self masterTableForNamespace: aString), ' where type = "table"'.
	  		s basicExecute: [ :row |
				(row dataValuesAvailable > 0) ifTrue: [ tables add: (row stringAt: 0) ]].
	  		s finalize.
			^ tables ]
]
