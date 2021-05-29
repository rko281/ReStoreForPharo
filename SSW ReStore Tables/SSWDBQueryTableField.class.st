"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBQueryTableField,
	#superclass : #SSWDBQueryField,
	#instVars : [
		'table',
		'accessorPath'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWDBQueryTableField class >> forField: anSSWDBField in: anSSWDBQueryTable [

	^self forField: anSSWDBField in: anSSWDBQueryTable path: #()
]

{ #category : #'instance creation' }
SSWDBQueryTableField class >> forField: anSSWDBField in: anSSWDBQueryTable path: anArray [

	^self new
		field: anSSWDBField;
		table: anSSWDBQueryTable;
		accessorPath: anArray;
		yourself
]

{ #category : #comparing }
SSWDBQueryTableField >> = anSSWDBField [

	^self == anSSWDBField or: [anSSWDBField = self field and: [anSSWDBField table = self table]]
]

{ #category : #accessing }
SSWDBQueryTableField >> accessorPath [

	"The path of accessors from some originating table to this field"

	^accessorPath
]

{ #category : #accessing }
SSWDBQueryTableField >> accessorPath: anObject [

	"The path of accessors from some originating table to this field"

	accessorPath := anObject
]

{ #category : #comparing }
SSWDBQueryTableField >> hash [

	^self table hash bitXor: self name hash
]

{ #category : #testing }
SSWDBQueryTableField >> isInlined [

	^self field isInlined
]

{ #category : #output }
SSWDBQueryTableField >> printOn: aStream [

	super printOn: aStream.
	aStream 
		nextPutAll: ' (';
		nextPutAll: self table name;
		nextPut: $.;
		nextPutAll: self name;
		nextPut: $)
]

{ #category : #accessing }
SSWDBQueryTableField >> table [

	"The receiver is created to stand in place of a regular SSWDBField when that field 
	is involved in a query where the same table is referenced more than once, via more than one field.

	Each reocurrence of the table is replaced (aliased) by an SSWDBQueryTable,
	and a reference to a field belonging to that table is replaced by an instance of the receiver's class.
	
	table stores the SSWDBQueryTable to which the receiver field belongs"
	
	^table
]

{ #category : #accessing }
SSWDBQueryTableField >> table: anSSWDBQueryTable [

	"The receiver is created to stand in place of a regular SSWDBField when that field 
	is involved in a query where the same table is referenced more than once, via more than one field.

	Each reocurrence of the table is replaced (aliased) by an SSWDBQueryTable,
	and a reference to a field belonging to that table is replaced by an instance of the receiver's class.
	
	table stores the SSWDBQueryTable to which the receiver field belongs"
	
	table := anSSWDBQueryTable
]

{ #category : #output }
SSWDBQueryTableField >> writeAliasedSQLOn: aStream [

	"For situations where duplicate field names are anticipated
	- write the SQL of the receiver on aStream, but use aliased names to force uniqueness"
	aStream nextPutAliasedField: self
]

{ #category : #output }
SSWDBQueryTableField >> writeSQLOn: aStream [

	"Use <table name>.<field name> notation to avoid ambiguity"
	
	self table writeSQLNameOn: aStream.
	
	aStream 
		nextPut: $.;
		nextPutIdentifier: self name
]
