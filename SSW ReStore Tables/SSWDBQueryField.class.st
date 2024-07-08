"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBQueryField',
	#superclass : 'Object',
	#instVars : [
		'field',
		'columnIndex'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'evaluating' }
SSWDBQueryField >> accessor [

	^self field accessor
]

{ #category : 'accessing' }
SSWDBQueryField >> accessorPath [

	^self field path
]

{ #category : 'testing' }
SSWDBQueryField >> canBeParameterized [

	"Defer to the field"
	^self field canBeParameterized
]

{ #category : 'accessing' }
SSWDBQueryField >> columnIndex [

	"columnIndex stores the expected index of the receiver's column in a DBRow after the most recent query involving the receiver.
	It is set during query result preparation and is checked first during subsequent lookups for this field"

	^columnIndex
]

{ #category : 'accessing' }
SSWDBQueryField >> columnIndex: anInteger [

	"columnIndex stores the expected index of the receiver's column in a DBRow after the most recent query involving the receiver.
	It is set during query result preparation and is checked first during subsequent lookups for this field"

	columnIndex := anInteger
]

{ #category : 'evaluating' }
SSWDBQueryField >> convertValue: aValue [

	"Forward to the real field"
	
	^self field convertValue: aValue
]

{ #category : 'accessing' }
SSWDBQueryField >> field [

	"The receiver is created to stand in place of a regular SSWDBField 
	See subclasses for when/why this may happen.
	
	field stores the original SSWDBField which the receiver replaces"
	
	^field
]

{ #category : 'accessing' }
SSWDBQueryField >> field: anSSWDBField [

	"The receiver is created to stand in place of a regular SSWDBField 
	See subclasses for when/why this may happen.
	
	field stores the original SSWDBField which the receiver replaces"

	field := anSSWDBField
]

{ #category : 'evaluating' }
SSWDBQueryField >> fieldNamed: aString [

	"Defer to the real field"
	^self field fieldNamed: aString
]

{ #category : 'testing' }
SSWDBQueryField >> hasAggregateFunction [

	"Defer to the field"
	^self field hasAggregateFunction
]

{ #category : 'testing' }
SSWDBQueryField >> isFieldCollection [

	^false
]

{ #category : 'accessing' }
SSWDBQueryField >> lookupIn: aDBRow [

	^aDBRow lookupField: self
]

{ #category : 'evaluating' }
SSWDBQueryField >> name [

	"Forward to the real field"
	
	^self field name
]

{ #category : 'accessing' }
SSWDBQueryField >> reStore [

	^self table reStore
]

{ #category : 'testing' }
SSWDBQueryField >> requiresAliasing [

	"Defer to the field"
	^self field requiresAliasing
]

{ #category : 'testing' }
SSWDBQueryField >> sqlCanBeParameterized [

	"When expressing this field as a value, can its SQL be parameterized?
	Different to canBeParameterized!"

	^false
]

{ #category : 'accessing' }
SSWDBQueryField >> table [

	^self field table
]

{ #category : 'accessing' }
SSWDBQueryField >> targetClass [

	"Forward to the real field"
	
	^self field targetClass
]

{ #category : 'accessing' }
SSWDBQueryField >> targetClass: aClass [
	
	aClass = self targetClass ifFalse: 
		[self field: 
			(self field withFunction: 
				('%1' asSQLFunction
					staticResultClass: aClass;
					yourself))]
]

{ #category : 'evaluating' }
SSWDBQueryField >> withFunction: aSQLFunction [

	"Return an SSWDBFunctionField base on the receiver with the given function"
	
	^self withFunction: aSQLFunction arguments: #()
]

{ #category : 'evaluating' }
SSWDBQueryField >> withFunction: aString arguments: aCollection [

	"Return an SSWDBFunctionField base on the receiver with the given function String and arguments"
	
	^SSWDBFunctionField new
		field: self;
		function: aString;
		arguments: aCollection;
		yourself
]

{ #category : 'printing' }
SSWDBQueryField >> writeSQLForUpdateOn: aStream [

	"Forward to the contained field"

	^self field writeSQLForUpdateOn: aStream
]
