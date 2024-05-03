"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLOrderedSelectQuery,
	#superclass : #SSWSQLSelectQuery,
	#instVars : [
		'orderingSpecs'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #'instance creation' }
SSWSQLOrderedSelectQuery class >> new [

	^super new
		orderingSpecs: OrderedCollection new;
		yourself
]

{ #category : #defining }
SSWSQLOrderedSelectQuery >> forgetOrdering [

	self orderingSpecs: OrderedCollection new
]

{ #category : #testing }
SSWSQLOrderedSelectQuery >> hasOrdering [

	^self orderingSpecs isEmpty not
]

{ #category : #defining }
SSWSQLOrderedSelectQuery >> orderAscendingBy: anSSWSQLDatabaseField [

	self orderingSpecs add: (SSWDBOrderingSpec ascending: anSSWSQLDatabaseField)
]

{ #category : #defining }
SSWSQLOrderedSelectQuery >> orderDescendingBy: anSSWSQLDatabaseField [

	self orderingSpecs add: (SSWDBOrderingSpec descending: anSSWSQLDatabaseField)
]

{ #category : #accessing }
SSWSQLOrderedSelectQuery >> orderingSpecs [

	"orderingSpecs stores an OrderedCollection of SSWDBOrderingSpecs
	which define the ordering used by this query (criteria is an SSWDBField)"
	
	^orderingSpecs
]

{ #category : #accessing }
SSWSQLOrderedSelectQuery >> orderingSpecs: anOrderedCollection [

	"orderingSpecs stores an OrderedCollection of SSWDBOrderingSpecs
	which define the ordering used by this query (criteria is an SSWDBField)"
	
	orderingSpecs := anOrderedCollection
]

{ #category : #output }
SSWSQLOrderedSelectQuery >> writeOrderingSQLOn: aStream [
	
	self orderingSpecs isEmpty ifTrue: [^self].

	aStream nextPutAll: ' ORDER BY '.

	self orderingSpecs do: 
		[ :spec |
		spec criteria writeSQLOn: aStream.
		spec isAscending
			ifTrue: [aStream nextPutAll: ' ASC ']
			ifFalse: [aStream nextPutAll: ' DESC ']] separatedBy: [aStream nextPutAll: ', ']
]

{ #category : #output }
SSWSQLOrderedSelectQuery >> writeSQLOn: aStream [

	self
		writeUnorderedSQLOn: aStream;
		writeOrderingSQLOn: aStream
]

{ #category : #output }
SSWSQLOrderedSelectQuery >> writeUnorderedSQLOn: aStream [

	super writeSQLOn: aStream
]
