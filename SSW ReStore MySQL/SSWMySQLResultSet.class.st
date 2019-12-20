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
SSWMySQLResultSet >> numRows [ 

	^rows size
]

{ #category : #accessing }
SSWMySQLResultSet >> size [

	^self numRows
]
