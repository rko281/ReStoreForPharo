"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLFieldValueConjunction',
	#superclass : 'Object',
	#instVars : [
		'field',
		'value'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLFieldValueConjunction class >> field: anSSWDBField value: aValue [

	^self new
		field: anSSWDBField;
		value: aValue;
		yourself
]

{ #category : 'comparing' }
SSWSQLFieldValueConjunction >> = anSSWSQLFieldValueConjunction [

	^self field = anSSWSQLFieldValueConjunction field and: [self value = anSSWSQLFieldValueConjunction value]
]

{ #category : 'accessing' }
SSWSQLFieldValueConjunction >> field [

	"field stores the single field which is the subject of the receiver SQL clause"
	
	^field
]

{ #category : 'accessing' }
SSWSQLFieldValueConjunction >> field: anSSWSQLField [

	"field stores the single field which is the subject of the receiver SQL clause"
	
	field := anSSWSQLField
]

{ #category : 'comparing' }
SSWSQLFieldValueConjunction >> hash [

	^self field hash

]

{ #category : 'accessing' }
SSWSQLFieldValueConjunction >> value [

	"value stores an object which is associated with the field in the receiver clause"
	
	^value
]

{ #category : 'accessing' }
SSWSQLFieldValueConjunction >> value: anObject [

	"value stores an object which is associated with the field in the receiver clause"

	value := anObject
]

{ #category : 'output' }
SSWSQLFieldValueConjunction >> writeConjunctionSQLOn: aStream [

	"Append to aStream whatever String/Character joins
	the receiver's field to the receiver's value"
	
	self subclassResponsibility
]

{ #category : 'output' }
SSWSQLFieldValueConjunction >> writeFieldSQLOn: aStream [

	self field writeSQLOn: aStream
]

{ #category : 'output' }
SSWSQLFieldValueConjunction >> writeSQLOn: aStream [

	self writeFieldSQLOn: aStream.
	aStream space.
	self writeConjunctionSQLOn: aStream.
	aStream space.
	self writeValueSQLOn: aStream
]

{ #category : 'output' }
SSWSQLFieldValueConjunction >> writeValueSQLOn: aStream [

	self value writeSQLOn: aStream forField: self field
]
