Class {
	#name : #SSWP3Statement,
	#superclass : #P3PreparedStatement,
	#instVars : [
		'query',
		'paramCols',
		'values',
		'sqlString',
		'lastResults'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #accessing }
SSWP3Statement >> client: aP3Connection [

	client := aP3Connection 
]

{ #category : #'initialize - release' }
SSWP3Statement >> client: aClient name: aString paramDescriptions: pCollection fieldDescriptions: fCollection [

	client := aClient.
	name := aString.
	paramDescriptions := pCollection.
	fieldDescriptions := fCollection
]

{ #category : #'initialize - release' }
SSWP3Statement >> close [

	self lastResults ifNotNil: [ :res | res close ]
]

{ #category : #executing }
SSWP3Statement >> exec [

	self execute: self values
]

{ #category : #public }
SSWP3Statement >> execute: someValues [

	^self query: someValues
]

{ #category : #'initialize - release' }
SSWP3Statement >> free [

	[super close] on: Error do: [  :x | x return: nil ]
]

{ #category : #accessing }
SSWP3Statement >> lastResults [
	^ lastResults
]

{ #category : #accessing }
SSWP3Statement >> lastResults: anObject [
	lastResults := anObject
]

{ #category : #public }
SSWP3Statement >> logQueryExecution [

	client debugStream ifNotNil: [ :stream | stream cr; show: self sqlString].
	client incrementQueryCount
]

{ #category : #'initialize - release' }
SSWP3Statement >> numRows [

	^self lastResults numRows
]

{ #category : #accessing }
SSWP3Statement >> objects: aCollection [

	self values: (aCollection collect: [ :each | each reStoreValue])
]

{ #category : #accessing }
SSWP3Statement >> paramCols [
	^ paramDescriptions
]

{ #category : #accessing }
SSWP3Statement >> query [
	^ query
]

{ #category : #executing }
SSWP3Statement >> query: someValues [

	client logQueryExecution: self sqlString.

	self lastResults: ((super query: someValues) query: self query; yourself).
	^self lastResults
	
]

{ #category : #accessing }
SSWP3Statement >> readValuesFrom: aStream [

	| size index |

	size := self paramCols size.
	self values: (Array new: size).
	index := 1.

	[aStream atEnd or: [index > size]] whileFalse: 
		[values at: index put: aStream next.
		index := index + 1]
]

{ #category : #accessing }
SSWP3Statement >> results [

	^self lastResults ifNil: [ self query: self values ]
]

{ #category : #'initialize - release' }
SSWP3Statement >> rowsAffected [

	^self lastResults rowsAffected
]

{ #category : #accessing }
SSWP3Statement >> setQuery: anSSWSQLQuery [
	query := anSSWSQLQuery 
]

{ #category : #accessing }
SSWP3Statement >> sqlDialect [

	^client sqlDialect
]

{ #category : #accessing }
SSWP3Statement >> sqlString [
	^ sqlString
]

{ #category : #accessing }
SSWP3Statement >> sqlString: anObject [
	sqlString := anObject
]

{ #category : #accessing }
SSWP3Statement >> values [
	^ values ifNil: [ #() ]
]

{ #category : #accessing }
SSWP3Statement >> values: anObject [
	values := anObject collect: [  :each | each reStoreValue ]
]
