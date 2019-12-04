Class {
	#name : #SSWDBCColAttr,
	#superclass : #Object,
	#instVars : [
		'name',
		'index',
		'tableName',
		'connection'
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

	declaration := (self connection declaredColumnTypesFor: self tableName) at: self index.
	stream := declaration readStream.
	[ stream atEnd or: [ stream peek isDigit ] ] whileFalse: [ stream next ].
	^stream atEnd
		ifTrue: [ nil ]
		ifFalse: [ Integer readFrom: stream ]
]

{ #category : #accessing }
SSWDBCColAttr >> tableName [
	^ tableName
]

{ #category : #accessing }
SSWDBCColAttr >> tableName: anObject [
	tableName := anObject
]
