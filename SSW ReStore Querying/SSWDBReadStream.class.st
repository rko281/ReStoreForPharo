"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBReadStream,
	#superclass : #PositionableStream,
	#instVars : [
		'instancesCollection',
		'peeked'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #evaluating }
SSWDBReadStream >> basicNext [

	peeked ifNotNil: [ :wasPeeked | peeked := nil. ^wasPeeked].

	"DBResultSet returns nil for next if atEnd"
	^self collectionNext
		ifNil: [self errorEndOfStream]
		ifNotNil: [ :row | self instancesCollection reStore objectFromRow: row table: self instancesCollection table]
]

{ #category : #actions }
SSWDBReadStream >> close [

	"Close the DBResultSet (and hence the DBStatement).
	Not essential as finalization will do this, but it is good practice"
	
	collection close
]

{ #category : #evaluating }
SSWDBReadStream >> collectionNext [

	"Private - Check for error - usually 'record deleted' "

	^[| next |
	next := collection next.
	position := position + 1.
	next] on: self reStore dbErrorClass do: 
		[ :exc |
		"If a 'deleted' error, skip until we find a valid next. Otherwise try resync"
		exc isRecordDeletedError
			ifTrue: [readLimit := readLimit - 1]
			ifFalse: [self resync].
		exc return: self collectionNext]
]

{ #category : #evaluating }
SSWDBReadStream >> evaluatePostReadActionsFor: aCollection [

	self instancesCollection postReadActions do: [ :each | each value: aCollection].

	^aCollection
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
SSWDBReadStream >> next [

	^self basicNext ifNotNil: 
		[ :next |
		self evaluatePostReadActionsFor: {next}.
		next]
]

{ #category : #evaluating }
SSWDBReadStream >> next: anInteger [

	| results |
	
	results := OrderedCollection new: anInteger.
	[self atEnd or: [results size = anInteger]] whileFalse: [results add: self basicNext].

	^self evaluatePostReadActionsFor: results
]

{ #category : #evaluating }
SSWDBReadStream >> nextAvailable: anInteger [

	| results count |
	
	results := OrderedCollection new: (count := anInteger).
	[count == 0 or: [self atEnd]] whileFalse: 
		[results add: self basicNext. 
		count := count - 1].

	^self evaluatePostReadActionsFor: results
]

{ #category : #evaluating }
SSWDBReadStream >> peek [

	^peeked ifNil: [peeked := self atEnd ifFalse: [self next]]
]

{ #category : #positioning }
SSWDBReadStream >> position: anInteger [

	collection position: anInteger.
	self resetPeeked.

	^super position: anInteger
]

{ #category : #accessing }
SSWDBReadStream >> reStore [

	^self instancesCollection reStore
]

{ #category : #initializing }
SSWDBReadStream >> reinitialize [

	self resetPeeked.
	self on: self instancesCollection resultSet.
	self setInstancesCollection: self instancesCollection
]

{ #category : #positioning }
SSWDBReadStream >> reset [

	self instancesCollection isNil ifFalse: [self resetResultsSet].
	^super reset
]

{ #category : #initializing }
SSWDBReadStream >> resetPeeked [

	peeked := nil
]

{ #category : #positioning }
SSWDBReadStream >> resetResultsSet [

	peeked := self instancesCollection reStore objectFromRow: collection resetAndFetchFirst table: self instancesCollection table
]

{ #category : #initializing }
SSWDBReadStream >> resync [

	"Private - Reinitialize the receiver by requerying"

	| oldPosition |

	oldPosition := self position.
	collection close.
	self reinitialize.

	self position: oldPosition
]

{ #category : #initializing }
SSWDBReadStream >> setInstancesCollection: anSSWDBInstancesCollection [

	self instancesCollection: anSSWDBInstancesCollection.

	"If the resultSet couldn't set the readLimit we have to query"
	readLimit isNil ifTrue: [readLimit := instancesCollection size]
]

{ #category : #evaluating }
SSWDBReadStream >> upTo: anObject [

	| results nextObject |
		
	results := OrderedCollection new: ((readLimit - position) // 2).
	[self atEnd or: [(nextObject := self basicNext) = anObject]] whileFalse: [results add: nextObject].

	^self evaluatePostReadActionsFor: results
]

{ #category : #evaluating }
SSWDBReadStream >> upToEnd [

	| results |
		
	results := OrderedCollection new: (readLimit - position).
	[self atEnd] whileFalse: [results add: self basicNext].

	^self evaluatePostReadActionsFor: results
]
