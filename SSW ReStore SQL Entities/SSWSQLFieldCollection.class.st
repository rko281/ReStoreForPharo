"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLFieldCollection,
	#superclass : #SSWSQLCollection,
	#type : #variable,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #accessing }
SSWSQLFieldCollection >> fieldNamed: aString [

	"Return the individual field with the given name"

	1 to: self size do: [ :index | ((self at: index) fieldNamed: aString) ifNotNil: [ :match | ^match]].

	^nil
]

{ #category : #testing }
SSWSQLFieldCollection >> isAll [

	"Since an empty field collection makes no sense, we use this to mean 'all fields' "
	
	^self isEmpty
]

{ #category : #testing }
SSWSQLFieldCollection >> isAllInTable [

	"Return whether the receiver represents all fields in a specific table,
	as opposed to all fields in a query, which is the definition of isAll.

	Technically this cannot be decided from the field collection alone 
	however we have a specific class to represent this concept.
	Hence - return false"
	
	^false
]

{ #category : #testing }
SSWSQLFieldCollection >> isFieldCollection [

	^true
]

{ #category : #testing }
SSWSQLFieldCollection >> requiresAliasing [

	"Query individual fields"
	^self anySatisfy: [ :each | each requiresAliasing]
]

{ #category : #output }
SSWSQLFieldCollection >> sqlConcatenator [

	"A comma is used to separate a list of tables in SQL"
	
	^', '
]

{ #category : #output }
SSWSQLFieldCollection >> writeAliasedSQLOn: aStream [

	"For situations where duplicate field names are anticipated
	- write the SQL of the receiver on aStream, but use aliased names to force uniqueness"

	self first writeAliasedSQLOn: aStream.
	
	2 to: self size do:
		[ :index || sqlEntity |
		sqlEntity := self at: index.
		aStream nextPutAll: self sqlConcatenator.
		sqlEntity writeAliasedSQLOn: aStream]
]

{ #category : #output }
SSWSQLFieldCollection >> writeSQLOn: aStream [

	^self isAll
		ifTrue: [aStream nextPut: $*]
		ifFalse: [super writeSQLOn: aStream]
]
