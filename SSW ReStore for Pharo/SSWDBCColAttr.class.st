Class {
	#name : #SSWDBCColAttr,
	#superclass : #Object,
	#instVars : [
		'name',
		'index',
		'table',
		'connection',
		'field'
	],
	#category : #'SSW ReStore for Pharo'
}

{ #category : #'instance creation' }
SSWDBCColAttr class >> forString: aString [

	^self new
]

{ #category : #accessing }
SSWDBCColAttr >> connection [
	^ connection
]

{ #category : #accessing }
SSWDBCColAttr >> connection: anObject [
	connection := anObject
]

{ #category : #accessing }
SSWDBCColAttr >> field [

	"field stores the SSWSQLField from a SELECT query 
	that gave rise to this column in the resut set"

	^field
]

{ #category : #accessing }
SSWDBCColAttr >> field: anSSWSQLField [

	"field stores the SSWSQLField from a SELECT query 
	that gave rise to this column in the resut set"

	field := anSSWSQLField
]

{ #category : #accessing }
SSWDBCColAttr >> fieldName [

	^self name
]

{ #category : #accessing }
SSWDBCColAttr >> index [
	^ index
]

{ #category : #accessing }
SSWDBCColAttr >> index: anObject [
	index := anObject
]

{ #category : #accessing }
SSWDBCColAttr >> name [
	^ name
]

{ #category : #accessing }
SSWDBCColAttr >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SSWDBCColAttr >> precision [ 

	^self size
]

{ #category : #accessing }
SSWDBCColAttr >> size [ 

	"Simple support, primarily for SUnits"

	| declaration stream |

	declaration := (self connection declaredColumnTypesForTable: self table) at: self index.
	stream := declaration readStream.
	[ stream atEnd or: [ stream peek isDigit ] ] whileFalse: [ stream next ].
	^stream atEnd
		ifTrue: [ nil ]
		ifFalse: [ Integer readFrom: stream ]
]

{ #category : #accessing }
SSWDBCColAttr >> table [
	^ table
]

{ #category : #accessing }
SSWDBCColAttr >> table: anObject [
	table := anObject
]

{ #category : #accessing }
SSWDBCColAttr >> tableName [
	^ self table name
]
