Class {
	#name : #SSWMySQLResultSet,
	#superclass : #MySQLResultSet,
	#category : #'SSW ReStore MySQL'
}

{ #category : #'initialize-release' }
SSWMySQLResultSet >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : #enumerating }
SSWMySQLResultSet >> do: aBlock [

	self rows do: aBlock
]

{ #category : #accessing }
SSWMySQLResultSet >> first [

	^rows isEmpty
		ifTrue: [ nil ] 
		ifFalse: [ rows first ]
]

{ #category : #accessing }
SSWMySQLResultSet >> last [

	^rows isEmpty
		ifTrue: [ nil ] 
		ifFalse: [ rows last ]
]

{ #category : #accessing }
SSWMySQLResultSet >> next [ 
	^self nextRow
]

{ #category : #accessing }
SSWMySQLResultSet >> numRows [ 

	^rows size
]

{ #category : #accessing }
SSWMySQLResultSet >> readStream [

	^SSWDBForwardOnlyReadStream on: self
]

{ #category : #accessing }
SSWMySQLResultSet >> rows: aCollection [

	statement isNil ifTrue: [^super rows: aCollection].
	
	super rows: (aCollection collect: [ :each | each asSSWMySQLRowFrom: statement query])
]

{ #category : #accessing }
SSWMySQLResultSet >> size [

	"size as in number of rows.
	nil = unknown"

	^nil
]

{ #category : #accessing }
SSWMySQLResultSet >> species [

	^OrderedCollection
]
