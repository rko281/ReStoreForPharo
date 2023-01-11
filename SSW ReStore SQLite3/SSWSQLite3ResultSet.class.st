Class {
	#name : #SSWSQLite3ResultSet,
	#superclass : #SQLite3Cursor,
	#instVars : [
		'firstRow',
		'query'
	],
	#pools : [
		'SQLite3Constants'
	],
	#category : #'SSW ReStore SQLite3'
}

{ #category : #initialization }
SSWSQLite3ResultSet >> close [
	" closing a cursor is not the same as closing the statement - we may reuse a prepared statement"
	statement ifNotNil: [ statement reset ].
	"Compared to the superclass we want to keep the statement"
	mutators := nil.
]

{ #category : #private }
SSWSQLite3ResultSet >> do: aBlock [

	[self next
		ifNil: [ false ]
		ifNotNil: [ :next | aBlock value: next. true]] whileTrue
]

{ #category : #accessing }
SSWSQLite3ResultSet >> first [
	^firstRow ifNil: [ self next ]
]

{ #category : #initialization }
SSWSQLite3ResultSet >> free [

	statement free
]

{ #category : #initialization }
SSWSQLite3ResultSet >> initialize [ 

	super initialize.
	self rowClass: SSWSQLite3Row 
]

{ #category : #private }
SSWSQLite3ResultSet >> keysAndValuesDo: aBlock [

	| index |
	
	index := 1.

	[self next
		ifNil: [ false ]
		ifNotNil: [ :next | aBlock value: index value: next. index := index + 1. true]] whileTrue
]

{ #category : #accessing }
SSWSQLite3ResultSet >> last [

	^self cachedRows last
]

{ #category : #API }
SSWSQLite3ResultSet >> next [

	^firstRow isNil 
		ifTrue: [ firstRow := super next ]
		ifFalse: [ super next ]
]

{ #category : #API }
SSWSQLite3ResultSet >> nextOfClass: aRowClass [

	| next |
	
	next := super nextOfClass: aRowClass.
	
	(next notNil and: [ self query notNil ]) ifTrue: [next createFieldMapFrom: self query].
	
	^next
]

{ #category : #accessing }
SSWSQLite3ResultSet >> numRows [

	^connection changes
]

{ #category : #accessing }
SSWSQLite3ResultSet >> query [

	^query
]

{ #category : #accessing }
SSWSQLite3ResultSet >> readStream [

	^SSWDBForwardOnlyReadStream on: self
]

{ #category : #accessing }
SSWSQLite3ResultSet >> results [

	^self
]

{ #category : #accessing }
SSWSQLite3ResultSet >> size [

	"size as in number of rows.
	nil = unknown"

	^nil
]

{ #category : #accessing }
SSWSQLite3ResultSet >> species [

	^OrderedCollection 
]

{ #category : #accessing }
SSWSQLite3ResultSet >> statement: anSSWSQLite3Statement [

	statement := anSSWSQLite3Statement.
	connection := anSSWSQLite3Statement parent
]

{ #category : #initialization }
SSWSQLite3ResultSet >> statement: aStatement moreRows: aBoolean rows: rCollection mutators: mCollection [

	statement := aStatement.
	connection := aStatement parent.
	query := aStatement query.
		
	moreRows := aBoolean.
	rows := rCollection.
	mutators := mCollection
]
