Class {
	#name : 'SSWDBColAttr',
	#superclass : 'Object',
	#instVars : [
		'name',
		'index',
		'table',
		'field'
	],
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'instance creation' }
SSWDBColAttr class >> forString: aString [

	^self new
]

{ #category : 'accessing' }
SSWDBColAttr >> connection [

	^self table reStore connection
]

{ #category : 'accessing' }
SSWDBColAttr >> field [

	"field stores the SSWSQLField from a SELECT query 
	that gave rise to this column in the resut set"

	^field
]

{ #category : 'accessing' }
SSWDBColAttr >> field: anSSWSQLField [

	"field stores the SSWSQLField from a SELECT query 
	that gave rise to this column in the resut set"

	field := anSSWSQLField
]

{ #category : 'accessing' }
SSWDBColAttr >> fieldName [

	^self name
]

{ #category : 'accessing' }
SSWDBColAttr >> index [
	^ index
]

{ #category : 'accessing' }
SSWDBColAttr >> index: anObject [
	index := anObject
]

{ #category : 'accessing' }
SSWDBColAttr >> name [
	^ name
]

{ #category : 'accessing' }
SSWDBColAttr >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
SSWDBColAttr >> precision [ 

	^self size
]

{ #category : 'accessing' }
SSWDBColAttr >> size [ 

	"Simple support, primarily for SUnits"

	| declaration stream |

	declaration := (self connection declaredColumnTypesForTable: self table) at: self index.
	stream := declaration readStream.
	[ stream atEnd or: [ stream peek isDigit ] ] whileFalse: [ stream next ].
	^stream atEnd
		ifTrue: [ nil ]
		ifFalse: [ Integer readFrom: stream ]
]

{ #category : 'accessing' }
SSWDBColAttr >> table [
	^ table
]

{ #category : 'accessing' }
SSWDBColAttr >> table: anObject [
	table := anObject
]

{ #category : 'accessing' }
SSWDBColAttr >> tableName [
	^ self table name
]
