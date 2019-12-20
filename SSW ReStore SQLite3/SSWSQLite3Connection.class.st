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

{ #category : #'as yet unclassified' }
SSWSQLite3Connection >> execute: aString [

	^ SSWSQLite3ResultSet new execute: aString 
		with: #() 
		on: self	
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

{ #category : #'connection open/close' }
SSWSQLite3Connection >> prepareToClose [

	"Allow resources to be finalized"
	Smalltalk garbageCollectMost
]

{ #category : #constants }
SSWSQLite3Connection >> sqlDialectClass [

	^SSWSQLiteDialect
]

{ #category : #accessing }
SSWSQLite3Connection >> tables [

	^self tableNames
]
