"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBReadStream,
	#superclass : #ReadStream,
	#instVars : [
		'instancesCollection'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #actions }
SSWDBReadStream >> atEnd [

	"Overriden to test via readLimit"
	
	^self position = readLimit
]

{ #category : #actions }
SSWDBReadStream >> atStart [

	^self position <= 1
]

{ #category : #actions }
SSWDBReadStream >> close [

	"Close the DBResultSet (and hence the DBStatement).
	Not essential as finalization will do this, but it is good practice"
	
	collection close
]

{ #category : #evaluating }
SSWDBReadStream >> collectionFirst [

	"Private - Check for error - usually 'record deleted' - requery"

	^[collection first] on: self reStore dbErrorClass do: 
		[ :exc | 
		self reinitialize.

		"Directly access the collection to prevent potential recursive error trapping"
		exc return: collection first]
]

{ #category : #evaluating }
SSWDBReadStream >> collectionLast [

	"Private - Check for error - usually 'record deleted' - requery"

	^[collection last] on: self reStore dbErrorClass do: 
		[ :exc | 
		self reinitialize.

		"Directly access the collection to prevent potential recursive error trapping"
		exc return: collection last]
]

{ #category : #evaluating }
SSWDBReadStream >> collectionNext [

	"Private - Check for error - usually 'record deleted' "

	^[collection next] on: self reStore dbErrorClass do: 
		[ :exc |
		"If a 'deleted' error, skip until we find a valid next. Otherwise try resync"
		exc isRecordDeletedError
			ifTrue: [readLimit := readLimit - 1]
			ifFalse: [self resync].
		exc return: self collectionNext]
]

{ #category : #evaluating }
SSWDBReadStream >> collectionPrevious [

	"Private - Check for error - usually 'record deleted' - requery"

	^[collection previous] on: self reStore dbErrorClass do: 
		[ :exc | 
		"Skip until we find a valid previous"
		exc isRecordDeletedError
		ifTrue: 
			[position := position - 1.
			readLimit := readLimit - 1]
		ifFalse: 
			[self resync].
		exc return: self collectionPrevious]
]

{ #category : #actions }
SSWDBReadStream >> errorStartOfStream [

	self error: 'start of stream reached'
]

{ #category : #evaluating }
SSWDBReadStream >> first [

	"Pass on to the receiver's collection (DBResultSet) which handles first"
	
	| row |
	
	row := self collectionFirst.
	
	"DBResultSet returns nil for first if empty"
	^row isNil
	ifTrue: 
		[self errorStartOfStream]
	ifFalse: 
		[position := 1.
		self instancesCollection reStore objectFromRow: row table: self instancesCollection table]
]

{ #category : #initializing }
SSWDBReadStream >> initialize [

	"Overriden to set readLimit from collection (DBResultSet) or instancesCollection,
	as most efficient"

	position := 0.

	"If the collection knows its numRows, use this else we have to query"	
	collection numRows = -1
		ifTrue: [readLimit := instancesCollection size]
		ifFalse: [readLimit := collection numRows]

]

{ #category : #accessing }
SSWDBReadStream >> instancesCollection [

	"instancesCollection stores the SSWDBInstancesCollection which the receiver
	is a stream 'onto' (in fact, a DBResultSet is the receiver's collection"
	
	^instancesCollection
]

{ #category : #accessing }
SSWDBReadStream >> instancesCollection: anSSWDBInstancesCollection [

	"instancesCollection stores the SSWDBInstancesCollection which the receiver
	is a stream 'onto' (in fact, a DBResultSet is the receiver's collection"
	
	instancesCollection := anSSWDBInstancesCollection
]

{ #category : #evaluating }
SSWDBReadStream >> last [

	"Pass on to the receiver's collection (DBResultSet) which handles last"
	
	| row |
	
	row := self collectionLast.
	
	"DBResultSet returns nil for next if atEnd"
	^row isNil
	ifTrue: 
		[self errorEndOfStream]
	ifFalse: 
		[position := readLimit.
		self instancesCollection reStore objectFromRow: row table: self instancesCollection table]
]

{ #category : #evaluating }
SSWDBReadStream >> next [

	"Pass on to the receiver's collection (DBResultSet) which handles next"
	
	| row |
	
	position = 0 ifTrue: [^self first].

	row := self collectionNext.
	
	"DBResultSet returns nil for next if atEnd"
	^row isNil
	ifTrue: 
		[self errorEndOfStream]
	ifFalse: 
		[position := position + 1.
		self instancesCollection reStore objectFromRow: row table: self instancesCollection table]
]

{ #category : #accessing }
SSWDBReadStream >> on: anSSWDBInstancesCollection [

	"Overriden to actually set the receiver's collection to a DBResultSet"
	
	self instancesCollection: anSSWDBInstancesCollection.
	
	super on: anSSWDBInstancesCollection resultSet
]

{ #category : #evaluating }
SSWDBReadStream >> position: anInteger [

	"Overriden to update the collection (DBResultSet)"
	
	super position: anInteger.
	collection at: anInteger
]

{ #category : #evaluating }
SSWDBReadStream >> previous [

	"Pass on to the receiver's collection (DBResultSet) which handles previous"
	
	| row |
		
	row := self collectionPrevious.

	"DBResultSet returns nil if at start"
	^row isNil
	ifTrue: 
		[self errorStartOfStream]
	ifFalse:
		[position := position - 1.
		self instancesCollection reStore objectFromRow: row table: self instancesCollection table]
]

{ #category : #accessing }
SSWDBReadStream >> reStore [

	^self instancesCollection reStore
]

{ #category : #initializing }
SSWDBReadStream >> reinitialize [

	"Reinitialize the receiver by requerying"
	collection close.
	collection := self instancesCollection resultSet.
	self initialize
]

{ #category : #initializing }
SSWDBReadStream >> resync [

	"Reinitialize the receiver by requerying"
	collection close.
	collection := self instancesCollection resultSet.
	self position: position
	
]

{ #category : #actions }
SSWDBReadStream >> setToEnd [

	"Overriden to set position via accessor"
	
	self position: readLimit
]

{ #category : #initializing }
SSWDBReadStream >> syncTo: aPersistentObject [

	| table idField id next |

	table := instancesCollection reStore tableForClass: aPersistentObject class.
	idField := table idField.
	id := aPersistentObject _id.

	"Reinitialize the receiver by requerying"
	collection close.
	collection := self instancesCollection resultSet.
	position := 0.

	[next := collection next.
	position := position + 1.
	next isNil or: [(next atField: idField) = id]] whileFalse.

	^next notNil
]
