Class {
	#name : #SSWSQLite3ResultSet,
	#superclass : #SQLite3Cursor,
	#instVars : [
		'cachedRows'
	],
	#pools : [
		'SQLite3Constants'
	],
	#category : #'SSW ReStore SQLite3'
}

{ #category : #accessing }
SSWSQLite3ResultSet >> cachedRows [

	^cachedRows ifNil: [ cachedRows := self rows ]
]

{ #category : #'initialize-release' }
SSWSQLite3ResultSet >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : #private }
SSWSQLite3ResultSet >> do: aBlock [

	[self next
		ifNil: [ false ]
		ifNotNil: [ :next | aBlock value: next. true]] whileTrue
]

{ #category : #API }
SSWSQLite3ResultSet >> execute [ 

	statement values keysAndValuesDo: [ :i :v | self execute: statement withIndex: i withValue: v ].
	moreRows := statement step = 100.	" == SQLITE_ROW "
	^self
]

{ #category : #accessing }
SSWSQLite3ResultSet >> first [

	^self cachedRows isEmpty 
		ifTrue: [ nil ] 
		ifFalse: [self cachedRows first]
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
SSWSQLite3ResultSet >> query [

	^statement query
]

{ #category : #accessing }
SSWSQLite3ResultSet >> size [

	^self numRows
]

{ #category : #accessing }
SSWSQLite3ResultSet >> statement: anSSWSQLite3Statement [

	statement := anSSWSQLite3Statement.
	connection := anSSWSQLite3Statement parent
]
