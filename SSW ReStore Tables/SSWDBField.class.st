"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBField,
	#superclass : #SSWDBTableComponent,
	#instVars : [
		'name',
		'isDependent',
		'isRelated'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #comparing }
SSWDBField >> = anSSWDBField [

	^self == anSSWDBField 
		or: [anSSWDBField notNil and: [self table = anSSWDBField table and: [self name = anSSWDBField name]]]
]

{ #category : #actions }
SSWDBField >> aboutToBeUnstored: anObject [

	"Delete the component of anObject referenced by the receiver, if dependent"

	self isDependent ifTrue: [(self accessor valueIn: anObject) unstore]

]

{ #category : #accessing }
SSWDBField >> accessorPath [

	"The path of accessors from some originating table to this field. 
	SSWDBFields are always first-level"

	^#()
]

{ #category : #defining }
SSWDBField >> beDependent [

	isDependent := true
]

{ #category : #defining }
SSWDBField >> beRelated [

	isRelated := true
]

{ #category : #defining }
SSWDBField >> beUnrelated [

	isRelated := false
]

{ #category : #testing }
SSWDBField >> canBeParameterized [

	^true
]

{ #category : #accessing }
SSWDBField >> fieldNamed: aString [

	"Polymorphic with field collections"

	^self name = aString 
		ifTrue: [self]
		ifFalse: [nil]
]

{ #category : #testing }
SSWDBField >> hasAggregateFunction [

	^false
]

{ #category : #comparing }
SSWDBField >> hash [

	^self table hash bitXor: self name hash
]

{ #category : #'initialize/release' }
SSWDBField >> initialize [

	super initialize.

	isDependent := false.
	isRelated := false
]

{ #category : #testing }
SSWDBField >> isAll [

	"The receiver is not the all fields (*) pseudo field"

	^false
]

{ #category : #testing }
SSWDBField >> isDependent [

	"isDependent indicates whether the receiver is marked as 'dependent', 
	i.e. whether the target object of the receiver depends on its source row for its existence, such that it will be deleted when it is no longer referenced by the source/source is deleted"
	
	^isDependent
]

{ #category : #testing }
SSWDBField >> isFieldCollection [

	"Just a single field"

	^false
]

{ #category : #testing }
SSWDBField >> isInlined [

	^self accessor isInlined
]

{ #category : #testing }
SSWDBField >> isRelated [

	"isRelated indicates whether the receiver field represents an object which is related to the owning/source object such that it will be commited/rolled-back with that object when withRelatedComponents is used"
	
	^isRelated
]

{ #category : #accessing }
SSWDBField >> name [

	"name stores the name of this field"
	
	^name
]

{ #category : #accessing }
SSWDBField >> name: aString [

	"name stores the name of this field"
	
	name := aString
]

{ #category : #printing }
SSWDBField >> printOn: aStream [

	super printOn: aStream.

	aStream
		nextPutAll: '>>';
		nextPutAll: self name
]

{ #category : #evaluating }
SSWDBField >> relatedComponentsOf: anObject do: aBlock [

	self isRelated ifTrue: [self componentsOf: anObject do: aBlock ]
]

{ #category : #testing }
SSWDBField >> requiresAliasing [

	"Return whether this field always requires aliasing"
	^false
]

{ #category : #testing }
SSWDBField >> sqlCanBeParameterized [

	"When expressing this field as a value, can its SQL be parameterized?
	Different to canBeParameterized!"

	^false
]

{ #category : #evaluating }
SSWDBField >> withFunction: aSQLFunction [

	"Return an SSWDBFunctionField base on the receiver with the given function"
	
	^self withFunction: aSQLFunction arguments: #()
]

{ #category : #evaluating }
SSWDBField >> withFunction: aString arguments: aCollection [

	"Return an SSWDBFunctionField base on the receiver with the given function String and arguments"
	
	^SSWDBFunctionField new
		field: self;
		function: aString;
		arguments: aCollection;
		yourself
]

{ #category : #output }
SSWDBField >> writeAliasedSQLOn: aStream [

	"For situations where duplicate field names are anticipated
	- write the SQL of the receiver on aStream, but use aliased names to force uniqueness"
	
	aStream nextPutAliasedField: self
]

{ #category : #output }
SSWDBField >> writeSQLDefinitionOn: aStream [

	aStream nextPutIdentifier: self name
]

{ #category : #printing }
SSWDBField >> writeSQLForUpdateOn: aStream [

	"Write the receiver field to aStream, specifically as part of an Update query.
	At present, ReStore only supports updates against one table (i.e. no joins).
	Hence the <table name>. prefix is unnecessary in update queries - in fact it is specifically disallowed in some DBs"

	^aStream nextPutIdentifier: self name
]

{ #category : #output }
SSWDBField >> writeSQLOn: aStream [

	"Use <table name>.<field name> notation to avoid ambiguity"

	self table writeSQLNameOn: aStream.

	aStream 
		nextPut: $.;
		nextPutIdentifier: self name
]
