Class {
	#name : #SSWSQLite3ResultSet,
	#superclass : #SQLite3Cursor,
	#instVars : [
		'query',
		'sqlString',
		'paramCols',
		'values',
		'cachedRows'
	],
	#pools : [
		'SQLite3Constants'
	],
	#category : #'SSW ReStore SQLite3'
}

{ #category : #accessing }
SSWSQLite3ResultSet >> cachedRows [

	^cachedRows ifNil: 
		[ cachedRows := OrderedCollection new.
		[ (self next ifNotNil: [ :next | cachedRows add:  next]) notNil] whileTrue.
		cachedRows ]
]

{ #category : #'initialize-release' }
SSWSQLite3ResultSet >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : #'initialize-release' }
SSWSQLite3ResultSet >> closeAfter: aBlock [

	^[aBlock value: self] ensure: [ self close ]
]

{ #category : #querying }
SSWSQLite3ResultSet >> describeParam: anInteger [

	^nil
]

{ #category : #private }
SSWSQLite3ResultSet >> do: aBlock [

	[self next
		ifNil: [ false ]
		ifNotNil: [ :next | aBlock value: next. true]] whileTrue
]

{ #category : #querying }
SSWSQLite3ResultSet >> exec [

	self execute: self sqlString withCollection: self values
]

{ #category : #querying }
SSWSQLite3ResultSet >> exec: aString [

	self sqlString: aString.
	self values: #().
	self paramCols: #().
	self exec
]

{ #category : #querying }
SSWSQLite3ResultSet >> execQuery: anSQLQuery [

	| stream |

	self query: anSQLQuery.

	stream := SSWSQLWriteStream newIn: self sqlDialect.
	anSQLQuery writeSQLOn: stream.
	self sqlString: stream contents.

	stream hasParameterizedFields ifTrue: 
		[paramCols := stream parameterizedColumnsFor: self.
		self values: stream parameterizedValues].

	self exec
]

{ #category : #private }
SSWSQLite3ResultSet >> execute: anSQLText withCollection: aCollection [
	| i |
	
	connection debugStream ifNotNil: [ :stream | stream nextPutAll: anSQLText ].
	connection incrementQueryCount.

	self prepareStatement: anSQLText.
	i := 1.
	cachedRows := nil.
	aCollection isNil ifFalse: [ aCollection do: [ :v | i := self execute: statement withIndex: i withValue: v ] ].
	moreRows := statement step = SQLITE_ROW
]

{ #category : #accessing }
SSWSQLite3ResultSet >> first [

	^self cachedRows isEmpty 
		ifTrue: [ nil ] 
		ifFalse: [self cachedRows first]
]

{ #category : #'initialize-release' }
SSWSQLite3ResultSet >> free [

	self statement free.
	statement := nil
]

{ #category : #initialization }
SSWSQLite3ResultSet >> initialize [ 

	super initialize.
	self rowClass: SSWSQLite3Row 
]

{ #category : #accessing }
SSWSQLite3ResultSet >> last [

	^self cachedRows last
]

{ #category : #API }
SSWSQLite3ResultSet >> nextOfClass: aRowClass [

	^(super nextOfClass: aRowClass) ifNotNil: 
		[ :row | 
		row
			createFieldMapFrom: self query; 
			yourself ]
]

{ #category : #accessing }
SSWSQLite3ResultSet >> numRows [

	^connection changes
]

{ #category : #accessing }
SSWSQLite3ResultSet >> paramCols [
	^ paramCols
]

{ #category : #accessing }
SSWSQLite3ResultSet >> paramCols: anObject [
	paramCols := anObject
]

{ #category : #accessing }
SSWSQLite3ResultSet >> parent [

	^connection
]

{ #category : #accessing }
SSWSQLite3ResultSet >> parent: aConnection [

	connection := aConnection
]

{ #category : #querying }
SSWSQLite3ResultSet >> prepareStatement: anSQLText [

	self sqlString: anSQLText .
	super prepareStatement: anSQLText.
	statement query: self query
]

{ #category : #accessing }
SSWSQLite3ResultSet >> query [
	^ query
]

{ #category : #accessing }
SSWSQLite3ResultSet >> query: anObject [
	query := anObject
]

{ #category : #accessing }
SSWSQLite3ResultSet >> readValuesFrom: aStream [

	| size index |

	size := self paramCols size.
	self values: (Array new: size).
	index := 1.

	[aStream atEnd or: [index > size]] whileFalse: 
		[values at: index put: aStream next.
		index := index + 1]
]

{ #category : #accessing }
SSWSQLite3ResultSet >> results [

	^self
]

{ #category : #accessing }
SSWSQLite3ResultSet >> rowsAffected [

	^self closeAfter: [ :stmt | stmt numRows ]
]

{ #category : #accessing }
SSWSQLite3ResultSet >> size [

	^self numRows
]

{ #category : #accessing }
SSWSQLite3ResultSet >> sqlDialect [

	^self parent sqlDialect
]

{ #category : #accessing }
SSWSQLite3ResultSet >> sqlString [
	^ sqlString
]

{ #category : #accessing }
SSWSQLite3ResultSet >> sqlString: anObject [
	sqlString := anObject
]

{ #category : #accessing }
SSWSQLite3ResultSet >> values [
	^ values
]

{ #category : #accessing }
SSWSQLite3ResultSet >> values: anObject [
	values := anObject collect: [  :each | each reStoreValue ]
]
