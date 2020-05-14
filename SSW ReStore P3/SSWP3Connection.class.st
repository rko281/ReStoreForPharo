Class {
	#name : #SSWP3Connection,
	#superclass : #P3Client,
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#instVars : [
		'statementCache'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #'connection open/close' }
SSWP3Connection >> basicClose [

	super close
]

{ #category : #'connection open/close' }
SSWP3Connection >> basicConnect [

	super connect
]

{ #category : #transactions }
SSWP3Connection >> beginTransaction [ 

	self execute: 'begin transaction'
]

{ #category : #accessing }
SSWP3Connection >> columnNamesForTable: aDBTable [

	^(self query: ('select column_name from information_schema.columns where table_name = <1p>;' expandMacrosWith: aDBTable name)) data collect: [ :each | each first ]
]

{ #category : #transactions }
SSWP3Connection >> commitTransaction [ 

	self execute: 'commit'
]

{ #category : #constants }
SSWP3Connection >> dbErrorClass [

	^P3Error
]

{ #category : #accessing }
SSWP3Connection >> declaredColumnTypesForTable: aDBTable [

	^(self query: ('SELECT data_type, character_maximum_length FROM information_schema.COLUMNS WHERE TABLE_NAME = <1p>;' expandMacrosWith: aDBTable name)) data collect: [ :each | each first asString, each second asString]
]

{ #category : #querying }
SSWP3Connection >> execute: query [

	"Override to return the raw results object.
	Convention says we should return a statement here, but they are compatible enough"

	^self query: query
]

{ #category : #querying }
SSWP3Connection >> prepare: aString [

	^self statementCache add: (self prepare: aString named: self statementCache size asString)
]

{ #category : #querying }
SSWP3Connection >> prepare: query named: queryName [

	^(super prepare: query named: queryName) asSSWP3Statement
		sqlString: query; 
		yourself
]

{ #category : #'connection open/close' }
SSWP3Connection >> prepareToClose [

	self statementCache isNil ifFalse: [self statementCache do: [ :each | each free ]]
]

{ #category : #printing }
SSWP3Connection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $$.
	anInteger printOn: aStream
]

{ #category : #'initialize-release' }
SSWP3Connection >> reset [

	self statementCache: (OrderedCollection new: 128)
]

{ #category : #transactions }
SSWP3Connection >> rollbackTransaction [ 

	self execute: 'rollback'
]

{ #category : #protocol }
SSWP3Connection >> runExtendedQueryResult: descriptions [
	^(super runExtendedQueryResult: descriptions) asSSWP3ResultSet
]

{ #category : #protocol }
SSWP3Connection >> runQueryResult [
	^super runQueryResult asSSWP3ResultSet
]

{ #category : #constants }
SSWP3Connection >> sqlDialectClass [ 

	^SSWPostgreSQLDialect
]

{ #category : #accessing }
SSWP3Connection >> statementCache [
	^statementCache
]

{ #category : #accessing }
SSWP3Connection >> statementCache: anOrderedCollection [
	statementCache := anOrderedCollection
]

{ #category : #accessing }
SSWP3Connection >> tablesInNamespace: aString [

	^(self listTablesInSchema: (aString ifNil: [self sqlDialect standardNamespace])) asOrderedCollection
]
