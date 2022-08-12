"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLField,
	#superclass : #SSWSQLTableComponent,
	#instVars : [
		'name'
	],
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #'instance creation' }
SSWSQLField class >> allFieldsInTable: anSSWSQLTable [

	"Create and return a 'field' to represent the SQL concept of all fields (*) for the given table"
	
	^self new
		table: anSSWSQLTable;
		name: '*';
		yourself
]

{ #category : #comparing }
SSWSQLField >> = anSSWDBField [

	^self == anSSWDBField 
		or: [self table = anSSWDBField table and: [self name = anSSWDBField name]]
]

{ #category : #testing }
SSWSQLField >> canBeParameterized [

	^true
]

{ #category : #accessing }
SSWSQLField >> fieldNamed: aString [

	"Polymorphic with field collections"

	^self name = aString 
		ifTrue: [self]
		ifFalse: [nil]
]

{ #category : #comparing }
SSWSQLField >> hash [

	^self table hash bitXor: self name hash
]

{ #category : #testing }
SSWSQLField >> isFieldCollection [

	"Just a single field"

	^false
]

{ #category : #accessing }
SSWSQLField >> name [

	"name stores the name of this field"
	
	^name
]

{ #category : #accessing }
SSWSQLField >> name: aString [

	"name stores the name of this field"
	
	name := aString
]

{ #category : #testing }
SSWSQLField >> requiresAliasing [

	"Return whether this field always requires aliasing"
	^false
]

{ #category : #testing }
SSWSQLField >> sqlCanBeParameterized [

	"When expressing this field as a value, can its SQL be parameterized?
	Different to canBeParameterized!"

	^false
]

{ #category : #evaluating }
SSWSQLField >> withFunction: aString arguments: aCollection [

	"Return an SSWSQLFunctionField base on the receiver with the given function String and arguments"
	
	^SSWSQLFunctionField new
		table: self table;
		name: self name;
		function: aString;
		arguments: aCollection;
		yourself
]

{ #category : #output }
SSWSQLField >> writeAliasedSQLOn: aStream [

	"For situations where duplicate field names are anticipated
	- write the SQL of the receiver on aStream, but use aliased names to force uniqueness"
	
	aStream nextPutAliasedField: self
]

{ #category : #output }
SSWSQLField >> writeSQLForUpdateOn: aStream [

	"Write the receiver field to aStream, specifically as part of an Update query.
	At present, ReStore only supports updates against one table (i.e. no joins).
	Hence the <table name>. prefix is unnecessary in update queries - in fact it is specifically disallowed in some DBs"

	^aStream nextPutIdentifier: self name
]

{ #category : #output }
SSWSQLField >> writeSQLOn: aStream [

	"Use <table name>.<field name> notation to avoid ambiguity"

	self table writeSQLNameOn: aStream.

	aStream 
		nextPut: $.;
		nextPutIdentifier: self name
]
