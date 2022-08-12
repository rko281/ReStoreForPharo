"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBTableComponent,
	#superclass : #SSWSQLTableComponent,
	#instVars : [
		'accessor',
		'readAllStatement'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWDBTableComponent class >> new [

	^super new initialize
]

{ #category : #actions }
SSWDBTableComponent >> aboutToBeUnstored: anSSWDBProxy [

	"anSSWDBProxy (which originated in the receiver's table) is about to be removed from the DB.
	Carry out any necessary actions"

	"Default - no action"
	^self
]

{ #category : #accessing }
SSWDBTableComponent >> accessor [

	"accessor stores an 'Accessor' object which is used to get and set the value
	represented by this component in its eventual Smalltalk object.
	The accessor does this via #valueIn: and value:in: - typically it is an SSWInstVarAccessor"
	
	^accessor
]

{ #category : #accessing }
SSWDBTableComponent >> accessor: anAccessor [

	"accessor stores an 'Accessor' object which is used to get and set the value
	represented by this component in its eventual Smalltalk object.
	The accessor does this via #valueIn: and value:in: - typically it is an SSWInstVarAccessor"
	
	accessor := anAccessor
]

{ #category : #evaluating }
SSWDBTableComponent >> componentsOf: anObject do: aBlock [

	"For each component of anObject represented by the receiver, evaluate aBlock"

	aBlock value: (self accessor valueIn: anObject)
]

{ #category : #'accessing-queries' }
SSWDBTableComponent >> newReadAllParameters [

	^Array new: self table readAllBatchSize
]

{ #category : #printing }
SSWDBTableComponent >> printOn: aStream [

	super printOn: aStream.

	aStream
		nextPutAll: ' - ';
		nextPutAll: self table name
]

{ #category : #accessing }
SSWDBTableComponent >> reStore [

	^self table reStore
]

{ #category : #actions }
SSWDBTableComponent >> readAllFor: aCollection [

	"Bulk-read (ideally in a single query, but possibly batched into several queries) all target objects of this table component belonging to any member of aCollection.
	The bulk-read objects are then assigned to the owning member of aCollection, thus avoiding (aCollection size) individual queries"

	self subclassResponsibility
]

{ #category : #'accessing-queries' }
SSWDBTableComponent >> readAllQuery [

	"Return a SQL query for reading all elements of this table component for a selection of owning objects"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBTableComponent >> readAllStatement [

	"Return a prepared statement for reading all elements of this table component for a selection of owning objects"

	^readAllStatement ifNil: [readAllStatement := self reStore prepareStatementForQuery: self readAllQuery]
]

{ #category : #evaluating }
SSWDBTableComponent >> relatedComponentsOf: anObject do: aBlock [

	"For each component of anObject represented by the receiver, which are related to anObject, evaluate aBlock"

	self subclassResponsibility
]

{ #category : #accessing }
SSWDBTableComponent >> sqlDialect [

	^self table sqlDialect
]
