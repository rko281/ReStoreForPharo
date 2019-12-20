Class {
	#name : #SSWSQLite3ResultSet,
	#superclass : #SQLite3Cursor,
	#instVars : [
		'cachedRows',
		'query'
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

{ #category : #private }
SSWSQLite3ResultSet >> do: aBlock [

	[self next
		ifNil: [ false ]
		ifNotNil: [ :next | aBlock value: next. true]] whileTrue
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

	^query
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

{ #category : #initialization }
SSWSQLite3ResultSet >> statement: aStatement moreRows: aBoolean rows: rCollection mutators: mCollection [

	statement := aStatement.
	connection := aStatement parent.
	query := aStatement query.
		
	moreRows := aBoolean.
	rows := rCollection.
	mutators := mCollection
]
