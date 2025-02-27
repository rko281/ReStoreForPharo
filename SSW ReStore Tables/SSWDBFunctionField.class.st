"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBFunctionField',
	#superclass : 'SSWDBQueryField',
	#instVars : [
		'function',
		'arguments'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'testing' }
SSWDBFunctionField >> anySatisfy: aBlock [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^aBlock value: self
]

{ #category : 'accessing' }
SSWDBFunctionField >> arguments [

	"arguments stores the collection of objects which are the arguments to the receiver's function.
	e.g. in the expression MID(SURNAME, 4, 9) the arguments would be #(4 9)"
	
	^arguments
]

{ #category : 'accessing' }
SSWDBFunctionField >> arguments: aCollection [

	"arguments stores the collection of objects which are the arguments to the receiver's function.
	e.g. in the expression MID(SURNAME, 4, 9) the arguments would be #(4 9)"
	
	arguments := aCollection
]

{ #category : 'helpers' }
SSWDBFunctionField >> convertValue: aValue [

	"Convert the given DB value object to the receiver's targetClass.
	Return the converted object"

	^self function convertValue: aValue forFunctionField: self
]

{ #category : 'accessing' }
SSWDBFunctionField >> fieldAtIndex: anInteger [

	^anInteger = 1
		ifTrue: [self field]
		ifFalse: [self arguments at: (anInteger - 1)]
]

{ #category : 'accessing' }
SSWDBFunctionField >> function [

	"function stores the SQL string of the function applied to the receiver's field,
	with %x placeholders for the arguments (at least one, for the receiver's field)
	e.g. for the expression SIZE(SURNAME), the function would be 'SIZE(%1)'	"
	
	^function
]

{ #category : 'accessing' }
SSWDBFunctionField >> function: aString [

	"function stores the SQL string of the function applied to the receiver's field,
	with %x placeholders for the arguments (at least one, for the receiver's field)
	e.g. for the expression SIZE(SURNAME), the function would be 'SIZE(%)'	"
	
	function := aString
]

{ #category : 'testing' }
SSWDBFunctionField >> hasAggregateFunction [

	^self function isAggregateFunction
]

{ #category : 'testing' }
SSWDBFunctionField >> isEmpty [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^false
]

{ #category : 'testing' }
SSWDBFunctionField >> requiresAliasing [

	"Function fields need aliasing for effective lookup, e.g. COUNT(ID) AS Field1"
	^true
]

{ #category : 'helpers' }
SSWDBFunctionField >> targetClass [

	^self function targetClassForFunctionField: self
]

{ #category : 'output' }
SSWDBFunctionField >> writeAliasedSQLOn: aStream [

	"The receiver does not support the concept of an 'aliased' name; 
	it either appears in conditions (alias not needed), or if in a result set it will be the sole field"
	
	^aStream nextPutAliasedField: self
]

{ #category : 'output' }
SSWDBFunctionField >> writeSQLOn: aStream [

	| funcStream |
	
	funcStream := ReadStream on: self function parameterizedString.

	[funcStream atEnd] whileFalse:
		["Handle doubled-up %%"
		[aStream nextPutAll: (funcStream upTo: $%).
		funcStream peek = $%] whileTrue: [aStream nextPut: funcStream next].

		funcStream atEnd ifFalse:
			[| argIndex |
			argIndex := funcStream next digitValue - 1.
			argIndex = 0
				ifTrue: [self field writeSQLOn: aStream]
				ifFalse: [(self arguments at: argIndex) writeSQLOn: aStream]]]
]
