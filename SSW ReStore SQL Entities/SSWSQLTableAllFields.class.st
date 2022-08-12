"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLTableAllFields,
	#superclass : #SSWSQLTableComponent,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #enumerating }
SSWSQLTableAllFields >> collect: aBlock [

	^aBlock value: self
]

{ #category : #accessing }
SSWSQLTableAllFields >> fieldNamed: aString [

	"Return the individual field with the given name"

	^self table fieldNamed: aString
]

{ #category : #testing }
SSWSQLTableAllFields >> hasAggregateFunction [

	^false
]

{ #category : #testing }
SSWSQLTableAllFields >> isAll [

	"Since the receiver is (conceptually) multiple fields, make it polymorphic with a field collection.
	Further - since the receiver is not the true 'all fields' concept (i.e all fields in a query), return false"

	^false
]

{ #category : #testing }
SSWSQLTableAllFields >> isAllInTable [

	^true
]

{ #category : #testing }
SSWSQLTableAllFields >> isEmpty [

	"Assume a table will always have at least one field"
	
	^false
]

{ #category : #testing }
SSWSQLTableAllFields >> isFieldCollection [

	"Effectively, yes"

	^true
]

{ #category : #enumerating }
SSWSQLTableAllFields >> reject: aBlock [

	"The receiver is indivisible"

	^self
]

{ #category : #testing }
SSWSQLTableAllFields >> requiresAliasing [

	"The 'all fields' concept does not require aliasing"
	^false
]

{ #category : #output }
SSWSQLTableAllFields >> writeAliasedSQLOn: aStream [

	"Workaround for SQLite which gives error with namespace.table_name.* "
	(self table hasNamespace and: [self table sqlDialect shouldExpandNamespacedAllFields]) ifTrue: [^self table allFields writeAliasedSQLOn: aStream].

	"Use <table name>.<field name> notation to avoid ambiguity"
	self table writeSQLNameOn: aStream.
	aStream nextPut: $..
	self writeSQLOn: aStream
]

{ #category : #output }
SSWSQLTableAllFields >> writeSQLOn: aStream [
	
	"Use an empty (i.e. 'all') field collection to handle the SQL representation of 'all'"
	SSWSQLFieldCollection new writeSQLOn: aStream
]
