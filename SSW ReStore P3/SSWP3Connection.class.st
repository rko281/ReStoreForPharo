Class {
	#name : #SSWP3Connection,
	#superclass : #P3Client,
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#instVars : [
		'activeQuery',
		'statementCache'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #accessing }
SSWP3Connection >> activeQuery [

	^activeQuery
]

{ #category : #accessing }
SSWP3Connection >> activeQuery: aSQLQuery [

	activeQuery := aSQLQuery
]

{ #category : #querying }
SSWP3Connection >> activeQuery: aSQLQuery during: aBlock [

	activeQuery := aSQLQuery.
	^[ aBlock value ] ensure: [ activeQuery := nil ]
]

{ #category : #'initialize-release' }
SSWP3Connection >> basicConnect [

	super connect.
	self statementCache: (OrderedCollection new: 128)
]

{ #category : #transactions }
SSWP3Connection >> beginTransaction [ 

	self execute: 'begin transaction'
]

{ #category : #'initialize-release' }
SSWP3Connection >> close [

	self statementCache isNil ifFalse: [self statementCache do: [ :each | each free ]].
	super close
]

{ #category : #accessing }
SSWP3Connection >> columnNamesFor: aString [

	^(self query: ('select column_name from information_schema.columns where table_name = <1p>;' expandMacrosWith: aString)) data collect: [ :each | each first ]
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
SSWP3Connection >> declaredColumnTypesFor: aTableName [

	^(self query: ('SELECT
        pg_catalog.format_type(a.atttypid, a.atttypmod) as "Datatype"
    FROM
        pg_catalog.pg_attribute a
    WHERE
        a.attnum > 0
        AND NOT a.attisdropped
        AND a.attrelid = (
            SELECT c.oid
            FROM pg_catalog.pg_class c
                LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relname ~ ''^(<1s>)$''
                AND pg_catalog.pg_table_is_visible(c.oid)
        );' expandMacrosWith: aTableName)) data collect: [ :each | each first ]
]

{ #category : #querying }
SSWP3Connection >> exec: aString [

	^self execute: aString
]

{ #category : #querying }
SSWP3Connection >> execute: aString [

	self logQueryExecution: aString.
	^super execute: aString
]

{ #category : #querying }
SSWP3Connection >> executeQuery: anSQLQuery cursorType: aSymbol [

	"Entry point for ad-hoc querying"

	anSQLQuery preExecIn: self.

	^self activeQuery: anSQLQuery during: 
		[| stream values statement |
		stream := SSWSQLWriteStream newIn: self sqlDialect.
		anSQLQuery writeSQLOn: stream.
		values := stream parameterizedValues collect: [ :each | each reStoreValue].
		statement := self prepare: stream contents.

		statement 
			setQuery: anSQLQuery;
			query: values]
]

{ #category : #querying }
SSWP3Connection >> logQueryExecution: aString [

	self debugStream ifNotNil: [ :stream | stream cr; show: aString].
	self incrementQueryCount
]

{ #category : #querying }
SSWP3Connection >> newStatement [ 

	^SSWP3Statement new
		client: self;
		yourself
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

{ #category : #querying }
SSWP3Connection >> prepareQuery: anSQLQuery [

	"Entry point for system-generated querying (read, refresh, insert).
	Prepare and return a parameterized statement for the execution of anSQLQuery"

	^(self prepare: (anSQLQuery sqlStringIn: self sqlDialect))
		setQuery: anSQLQuery;
		yourself 
]

{ #category : #printing }
SSWP3Connection >> printParameterPlaceholder: anInteger on: aStream [

	aStream nextPut: $$.
	anInteger printOn: aStream
]

{ #category : #transactions }
SSWP3Connection >> rollbackTransaction [ 

	self execute: 'rollback'
]

{ #category : #protocol }
SSWP3Connection >> runExtendedQueryResult: descriptions [
	"Read DataRow ($D) messages until either a CommandComplete ($C) or PortalSuspended ($s) message is received."

	| rows |

			"Check for BindComplete message"
	message tag = $2
		ifFalse: [ ^ self error: 'BindComplete message expected' ].
	self readMessage.

	rows := Array streamContents: [ :out |
		[ 'Cs' includes: message tag ] whileFalse: [ 
			self assert: message tag = $D.
			out nextPut: (self processDataRowUsing: descriptions).
			self readMessage ] ].
	
	^ SSWP3Result descriptions: descriptions
			rows: rows 
			message: (self converter asciiCStringFrom: message readStream)
]

{ #category : #protocol }
SSWP3Connection >> runQueryResult [
	^super runQueryResult asSSWP3Result
		query: self activeQuery; 
		yourself
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
SSWP3Connection >> tables [

	^self listTablesInSchema: 'public'
]
