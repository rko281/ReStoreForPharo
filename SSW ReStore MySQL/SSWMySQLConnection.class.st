Class {
	#name : #SSWMySQLConnection,
	#superclass : #MySQLDriver,
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#instVars : [
		'connectionSpec'
	],
	#category : #'SSW ReStore MySQL'
}

{ #category : #'connection open/close' }
SSWMySQLConnection >> basicClose [

	self disconnect
]

{ #category : #'connection open/close' }
SSWMySQLConnection >> basicConnect [

	| result |

	result := self connect: self connectionSpec.
	result isError ifTrue: [ result signalError ]
]

{ #category : #transactions }
SSWMySQLConnection >> beginTransaction [
	
	self query: 'BEGIN'
]

{ #category : #'as yet unclassified' }
SSWMySQLConnection >> columnNamesForTable: aDBTable [

	| stream |
	
	stream := self sqlDialect sqlWriteStream.
	stream nextPutAll: 'SHOW COLUMNS FROM '; writeSQLFor: aDBTable.

	^(self execute: stream contents) collect: [ :row | row first ]
]

{ #category : #transactions }
SSWMySQLConnection >> commitTransaction [
	
	self query: 'COMMIT'
]

{ #category : #accessing }
SSWMySQLConnection >> connectionSpec [
	^ connectionSpec
]

{ #category : #accessing }
SSWMySQLConnection >> connectionSpec: anObject [
	connectionSpec := anObject
]

{ #category : #'public API - introspection' }
SSWMySQLConnection >> dbErrorClass [

	^MySQLDriverError
]

{ #category : #enquiries }
SSWMySQLConnection >> declaredColumnTypesForTable: aDBTable [

	| stream |
	
	stream := self sqlDialect sqlWriteStream.
	stream nextPutAll: 'SHOW COLUMNS FROM '; writeSQLFor: aDBTable.

	^(self execute: stream contents) collect: [ :row | (row atIndex: 2) asString ]
]

{ #category : #'error handling' }
SSWMySQLConnection >> error: aString [

	"Use the expected dbErrorClass"
	
	^self dbErrorClass signal: aString
]

{ #category : #running }
SSWMySQLConnection >> execute: aString [

	^(self query: aString) asSSWMySQLResultSet
]

{ #category : #testing }
SSWMySQLConnection >> isConnected [

	^self connected
]

{ #category : #accessing }
SSWMySQLConnection >> prepare: queryString [

	| response |

	response := super prepare: queryString.
	response isError ifTrue: [ response signalError ].

	^ (SSWMySQLStatement onConnection: self)
		stmtId: response prepareOkay stmtHandlerId;
		sqlString: queryString;
		cursoredFetch: false;
		typeMapResults: false;
		yourself
]

{ #category : #transactions }
SSWMySQLConnection >> rollbackTransaction [
	
	self query: 'ROLLBACK'
]

{ #category : #constants }
SSWMySQLConnection >> sqlDialectClass [

	^SSWMySQLDialect
]

{ #category : #accessing }
SSWMySQLConnection >> tablesInNamespace: aString [

	^(((aString isNil or: [aString = self sqlDialect standardNamespace])
		ifTrue: [ self execute: 'SHOW TABLES' ]
		ifFalse: [ self execute: 'SHOW TABLES IN ', (self sqlDialect asIdentifier: aString) ]) collect: [ :row | row first ]) asOrderedCollection
]
