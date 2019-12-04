"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBTableRecord,
	#superclass : #Object,
	#instVars : [
		'tableName',
		'fullTableName',
		'nextID'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #persistence }
SSWDBTableRecord class >> preferredObjectProxyClass [ 

	^SSWDBCachingObjectProxy
]

{ #category : #persistence }
SSWDBTableRecord class >> tableIn: anSSWReStore [

	| table |
	
	table := SSWDBTable forClass: self in: anSSWReStore.

	table
		name: (anSSWReStore sqlDialect transformClassName: #NextID);	"Name for historical reasons"
		define: #tableName as: (String maxSize: anSSWReStore sqlDialect maxTableNameLength);
		define: #nextID as: Integer.

	anSSWReStore supportsFullTableRecords ifTrue:
		[table define: #fullTableName as: (String maxSize: 255)].

	^table
		
]

{ #category : #accessing }
SSWDBTableRecord >> _proxiedObject [

	"The receiver is always non-persistent. 
	Answer the receiver for compatability with a persistent proxy"

	^self
]

{ #category : #accessing }
SSWDBTableRecord >> fullTableName [

	"fullTableName stores the full-length name of the table related to the receiver.
	This will usually be the same as the tableName. However, where the size of 
	the fullTableName is greater than the max length supported by the database,
	then tableName will contain an auto-abbreviated version"
	
	"Backwards-compatability: nil fullTableName means tableName == fullTableName"
	^fullTableName ifNil: [tableName]
]

{ #category : #accessing }
SSWDBTableRecord >> fullTableName: aString [

	"fullTableName stores the full-length name of the table related to the receiver.
	This will usually be the same as the tableName. However, where the size of 
	the fullTableName is greater than the max length supported by the database,
	then tableName will contain an auto-abbreviated version"
	
	fullTableName := aString
]

{ #category : #updating }
SSWDBTableRecord >> incrementNextIDBy: anInteger [

	self nextID: (self nextID + anInteger)
]

{ #category : #accessing }
SSWDBTableRecord >> nextID [

	"nextID stores the next available ID value for the receiver's table, as stored in the database"
	
	^nextID
]

{ #category : #accessing }
SSWDBTableRecord >> nextID: anInteger [

	"nextID stores the next available ID value for the receiver's table, as stored in the database"
	
	nextID := anInteger
]

{ #category : #accessing }
SSWDBTableRecord >> tableName [

	"tableName stores the name (String) of the SSWDBTable 
	for which the receiver maintains the next available IDs"
	
	^tableName
]

{ #category : #accessing }
SSWDBTableRecord >> tableName: aString [

	"tableName stores the name (String) of the SSWDBTable 
	for which the receiver maintains the next available IDs"
	
	tableName := aString
]
