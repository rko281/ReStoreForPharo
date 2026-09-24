Class {
	#name : 'SSWMySQLConnection',
	#superclass : 'MySQLDriver',
	#traits : 'SSWReStoreDBConnection',
	#classTraits : 'SSWReStoreDBConnection classTrait',
	#instVars : [
		'connectionSpec'
	],
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'instance creation' }
SSWMySQLConnection class >> on: aMySQLDriverSpec [

	^self new 
		connectionSpec: aMySQLDriverSpec;
		yourself
]

{ #category : 'connection open/close' }
SSWMySQLConnection >> basicClose [

	self connected ifTrue: [self disconnect]
]

{ #category : 'connection open/close' }
SSWMySQLConnection >> basicConnect [

	| result |

	result := self connect: self connectionSpec.
	result isError ifTrue: [ result signalError ]
]

{ #category : 'transactions' }
SSWMySQLConnection >> beginTransaction [
	
	self query: 'BEGIN'
]

{ #category : 'accessing' }
SSWMySQLConnection >> columnNamesForTable: aDBTable [

	| stream |
	
	stream := self sqlDialect sqlWriteStream.
	stream nextPutAll: 'SHOW COLUMNS FROM '; writeSQLFor: aDBTable.

	^(self execute: stream contents) collect: [ :row | row first ]
]

{ #category : 'accessing' }
SSWMySQLConnection >> commandQueryClass [

	^SSWMySQLCommandQuery
]

{ #category : 'transactions' }
SSWMySQLConnection >> commitTransaction [
	
	self query: 'COMMIT'
]

{ #category : 'accessing' }
SSWMySQLConnection >> connectionSpec [
	^ connectionSpec
]

{ #category : 'accessing' }
SSWMySQLConnection >> connectionSpec: anObject [
	connectionSpec := anObject
]

{ #category : 'public API - introspection' }
SSWMySQLConnection >> dbErrorClass [

	^MySQLDriverError
]

{ #category : 'public API - introspection' }
SSWMySQLConnection >> dbmsName [

	^SSWMySQLDialect dbmsName
]

{ #category : 'public API - introspection' }
SSWMySQLConnection >> dbmsVersion [

	^[(self query: 'select version()') rows first atIndex: 1] on: Error do: [ :exc | exc return: '']
]

{ #category : 'enquiries' }
SSWMySQLConnection >> declaredColumnTypesForTable: aDBTable [

	| stream |
	
	stream := self sqlDialect sqlWriteStream.
	stream nextPutAll: 'SHOW COLUMNS FROM '; writeSQLFor: aDBTable.

	^(self execute: stream contents) collect: [ :row | (row atIndex: 2) asString ]
]

{ #category : 'error handling' }
SSWMySQLConnection >> error: aString [

	"Use the expected dbErrorClass"
	
	^self dbErrorClass signal: aString
]

{ #category : 'running' }
SSWMySQLConnection >> execute: aString [

	| result |

	result := self query: aString.
	result isError ifTrue: [result signalError].
	^result
]

{ #category : 'testing' }
SSWMySQLConnection >> isConnected [

	^self connected
]

{ #category : 'testing' }
SSWMySQLConnection >> isMariaDB [

	^'*MariaDB*' match: self versionString
]

{ #category : 'connection open/close' }
SSWMySQLConnection >> postConnect [

	self syncTimeZone.
	self sqlDialect onConnected: self
]

{ #category : 'accessing' }
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

{ #category : 'transactions' }
SSWMySQLConnection >> rollbackTransaction [
	
	self query: 'ROLLBACK'
]

{ #category : 'constants' }
SSWMySQLConnection >> sqlDialectClass [

	^self isMariaDB
		ifTrue: [SSWMariaDBNativeDialect]
		ifFalse: [SSWMySQLNativeDialect]
]

{ #category : 'connection open/close' }
SSWMySQLConnection >> syncTimeZone [

	| localeOffset |

	"Ensure the session timezone matches the Locale"
	localeOffset := DateAndTime localOffset.
	self utcOffset = localeOffset 
		ifTrue: [MySQLBinaryReader default utcOffset: nil]
		ifFalse: [self utcOffset: localeOffset]
]

{ #category : 'accessing' }
SSWMySQLConnection >> tablesInNamespace: aString [

	^(((aString isNil or: [aString = self sqlDialect standardNamespace])
		ifTrue: [ self execute: 'SHOW TABLES' ]
		ifFalse: [ self execute: 'SHOW TABLES IN ', (self sqlDialect asIdentifier: aString) ]) collect: [ :row | row first ]) asOrderedCollection
]

{ #category : 'public API - introspection' }
SSWMySQLConnection >> utcOffset [

	"Query result will be a Time if positive or Duration if negative"
	^Duration seconds: ((self exec: 'SELECT TIMEDIFF(NOW(), UTC_TIMESTAMP);') first at: 1) asSeconds
]

{ #category : 'public API - introspection' }
SSWMySQLConnection >> utcOffset: aDuration [

	self exec: 'set @@session.time_zone = <1p>' << ((aDuration positive ifTrue: [ '+', (aDuration printString allButFirst: 2) ] ifFalse: [ '-', (aDuration printString allButFirst: 3) ]) allButLast: 3).

	"Also update the reader"
	MySQLBinaryReader default utcOffset: aDuration
]

{ #category : 'accessing' }
SSWMySQLConnection >> versionString [

	^(self query: 'select version()') rows first at: 1
]
