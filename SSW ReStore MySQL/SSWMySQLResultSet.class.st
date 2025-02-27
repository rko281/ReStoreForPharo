Class {
	#name : 'SSWMySQLResultSet',
	#superclass : 'MySQLResultSet',
	#instVars : [
		'columns'
	],
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'initialize-release' }
SSWMySQLResultSet >> close [

	"In Dolphin this closes the result set, leaving the statement open.
	Nothing to do here"
]

{ #category : 'enumerating' }
SSWMySQLResultSet >> collect: aBlock [

	^self rows collect: aBlock
]

{ #category : 'accessing' }
SSWMySQLResultSet >> columns [

	^columns
]

{ #category : 'accessing' }
SSWMySQLResultSet >> cursorType [

	^#forwardOnly
]

{ #category : 'enumerating' }
SSWMySQLResultSet >> do: aBlock [

	self rows do: aBlock
]

{ #category : 'accessing' }
SSWMySQLResultSet >> first [

	^rows isEmpty
		ifTrue: [ nil ] 
		ifFalse: [ rows first ]
]

{ #category : 'initialize-release' }
SSWMySQLResultSet >> free [

	statement free
]

{ #category : 'enumerating' }
SSWMySQLResultSet >> keysAndValuesDo: aBlock [

	self rows keysAndValuesDo: aBlock
]

{ #category : 'accessing' }
SSWMySQLResultSet >> last [

	^rows isEmpty
		ifTrue: [ nil ] 
		ifFalse: [ rows last ]
]

{ #category : 'accessing' }
SSWMySQLResultSet >> next [ 
	^self nextRow
		columns: self columns;
		yourself
]

{ #category : 'accessing' }
SSWMySQLResultSet >> numRows [ 

	^rows size
]

{ #category : 'accessing' }
SSWMySQLResultSet >> readStream [

	^SSWDBForwardOnlyReadStream on: self
]

{ #category : 'accessing' }
SSWMySQLResultSet >> size [

	"size as in number of rows.
	nil = unknown"

	^nil
]

{ #category : 'accessing' }
SSWMySQLResultSet >> species [

	^OrderedCollection
]

{ #category : 'accessing' }
SSWMySQLResultSet >> statement: anSSWMySQLStatement [

	| query |

	super statement: anSSWMySQLStatement.
	fields isEmpty ifTrue: [^self].

	statement adoptResultSet: self.
	query := statement query.
	columns :=  fields collect: 
		[ :each | 
		SSWDBCColAttr new 
			name: each name; 
			field:  (query fieldNamed: each name);
			yourself].

	rows ifNotNil: [rows do: [ :each | each columns: columns]]
]
