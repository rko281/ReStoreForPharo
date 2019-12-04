Class {
	#name : #SSWUDBCSQLite3ResultSet,
	#superclass : #UDBCSQLite3ResultSet,
	#instVars : [
		'query',
		'sqlString',
		'paramCols',
		'values',
		'cachedRows'
	],
	#category : #'SSW ReStore UDBC SQLite'
}

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> cachedRows [

	^cachedRows ifNil: 
		[ cachedRows := OrderedCollection new.
		[ (self next ifNotNil: [ :next | cachedRows add:  next]) notNil] whileTrue.
		cachedRows ]
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> closeAfter: aBlock [

	^[aBlock value: self] ensure: [ self close ]
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> describeParam: anInteger [

	^nil
]

{ #category : #private }
SSWUDBCSQLite3ResultSet >> do: aBlock [

	[self next
		ifNil: [ false ]
		ifNotNil: [ :next | aBlock value: next. true]] whileTrue
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> exec [

	self execute: self sqlString withCollection: self values
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> exec: aString [

	self sqlString: aString.
	self values: #().
	self paramCols: #().
	self exec
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> execQuery: anSQLQuery [

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
SSWUDBCSQLite3ResultSet >> execute: anSQLText withCollection: aCollection [
	| i |
	
	db debugStream ifNotNil: [ :stream | stream nextPutAll: anSQLText ].
	db incrementQueryCount.

	self prepareStatement: anSQLText.
	i := 1.
	cachedRows := nil.
	aCollection isNil ifFalse: [ aCollection do: [ :v | i := self execute: statement withIndex: i withValue: v ] ].
	moreRows := statement step = 100	" == SQLITE_ROW "
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> first [

	^self cachedRows isEmpty 
		ifTrue: [ nil ] 
		ifFalse: [self cachedRows first]
]

{ #category : #'initialize-release' }
SSWUDBCSQLite3ResultSet >> free [

	self close
]

{ #category : #initialization }
SSWUDBCSQLite3ResultSet >> initialize [ 

	super initialize.
	self rowClass: SSWUDBCSQLite3Row 
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> last [

	^self cachedRows last
]

{ #category : #API }
SSWUDBCSQLite3ResultSet >> nextOfClass: aRowClass [

	^(super nextOfClass: aRowClass) ifNotNil: 
		[ :row | 
		row
			createFieldMapFrom: self query; 
			yourself ]
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> numRows [

	^db changes
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> paramCols [
	^ paramCols
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> paramCols: anObject [
	paramCols := anObject
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> parent [

	^db
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> parent: aConnection [

	db := aConnection
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> prepareStatement: anSQLText [

	self sqlString: anSQLText .
	super prepareStatement: anSQLText.
	statement query: self query
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> query [
	^ query
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> query: anObject [
	query := anObject
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> readValuesFrom: aStream [

	| size index |

	size := self paramCols size.
	self values: (Array new: size).
	index := 1.

	[aStream atEnd or: [index > size]] whileFalse: 
		[values at: index put: aStream next.
		index := index + 1]
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> results [

	^self
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3ResultSet >> rowsAffected [

	^self closeAfter: [ :stmt | stmt numRows ]
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> size [

	^self numRows
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> sqlDialect [

	^self parent sqlDialect
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> sqlString [
	^ sqlString
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> sqlString: anObject [
	sqlString := anObject
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> values [
	^ values
]

{ #category : #accessing }
SSWUDBCSQLite3ResultSet >> values: anObject [
	values := anObject collect: [  :each | each reStoreValue ]
]
