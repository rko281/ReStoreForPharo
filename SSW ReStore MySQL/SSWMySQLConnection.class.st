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

	self connect: self connectionSpec
]

{ #category : #transactions }
SSWMySQLConnection >> beginTransaction [
	
	self query: 'BEGIN'
]

{ #category : #'public API - introspection' }
SSWMySQLConnection >> columnNamesFor: aTableName [

	^(self execute: 'SHOW COLUMNS FROM ', (self sqlDialect asIdentifier: aTableName)) collect: [ :row | row first ]
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

{ #category : #'public API - introspection' }
SSWMySQLConnection >> declaredColumnTypesFor: aTableName [

	^(self query: 'SHOW COLUMNS FROM ', (self sqlDialect asIdentifier: aTableName)) collect: [ :each | (each atIndex: 2) asString ]
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

	^(SSWMySQLStatement onConnection: self)
		stmtId: (super prepare: queryString) prepareOkay stmtHandlerId; 
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
SSWMySQLConnection >> tables [

	^(self execute: 'SHOW TABLES') collect: [ :row | row first ]
]
