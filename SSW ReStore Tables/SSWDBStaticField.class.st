"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBStaticField,
	#superclass : #SSWDBField,
	#instVars : [
		'targetClass'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #actions }
SSWDBStaticField >> applyValueFromRow: aDBRow to: anObject [

	self accessor value: (self convertValue: (aDBRow lookupField: self)) in: anObject
]

{ #category : #actions }
SSWDBStaticField >> applyValueIfChangedFromRow: aDBRow to: anObject [

	"Return whether a change was applied"

	^self accessor valueIfChanged: (self convertValue: (aDBRow lookupField: self)) in: anObject
]

{ #category : #actions }
SSWDBStaticField >> convertValue: aValue [

	"Convert the given DB value object to the receiver's targetClass.
	Return the converted object"
	
	^self targetClass instanceFromDBValue: aValue in: self reStore
]

{ #category : #public }
SSWDBStaticField >> isValidForPersistence [

	^true
]

{ #category : #actions }
SSWDBStaticField >> readAllFor: aCollection [

	| ids stream allResults |

	ids := aCollection inject: Set new into: [ :all :each | (self accessor valueIn: each) ifNotNil: [ :proxy | proxy isDBProxy ifTrue: [all add: proxy _id]]. all].
	ids isEmpty ifTrue: [^self].

	stream := ReadStream on: ids asArray.

	"We don't actually use the results (they will be put into the appropriate proxy) but the fetch method requires a collection"
	allResults := OrderedCollection new: ids size.
	[stream atEnd] whileFalse: 
		[self readAllStatement readValuesFrom: stream.
		self reStore fetchObjectsOfClass: self targetClass withStatement: self readAllStatement into: allResults]
]

{ #category : #accessing }
SSWDBStaticField >> readAllQuery [

	| params |

	params := self newReadAllParameters.
	params atAllPut: SSWSQLQueryParameter.

	^ SSWSQLSelectQuery new
		table: self targetTable;
		conditions: (SSWSQLCondition field: self targetTable idField is: (SSWSQLOperator messageSelector: #includedIn:) to: params);
		yourself
]

{ #category : #accessing }
SSWDBStaticField >> targetClass [

	"targetClass stores the Class of object stored in this field.
	This can be a base class with an SQL equivalent (String, Number, Date...), or a persistent class"
	
	^targetClass
]

{ #category : #accessing }
SSWDBStaticField >> targetClass: aClass [

	"targetClass stores the Class of object stored in this field.
	This can be a base class with an SQL equivalent (String, Number, Date...), or a persistent class"
	
	targetClass := aClass
]

{ #category : #accessing }
SSWDBStaticField >> targetTable [

	"ASSERT: targetClass is not a base class"

	^self reStore tableForClass: self targetClass
]

{ #category : #output }
SSWDBStaticField >> writeSQLDefinitionOn: aStream [
	
	super writeSQLDefinitionOn: aStream.
	aStream space.
	self targetClass writeSQLTypeOn: aStream using: self sqlDialect
]
