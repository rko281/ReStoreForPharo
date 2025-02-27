"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLInsertQuery',
	#superclass : 'SSWSQLObjectQuery',
	#category : 'SSW ReStore SQL Queries',
	#package : 'SSW ReStore SQL Queries'
}

{ #category : 'output' }
SSWSQLInsertQuery >> fields [

	"Return the fields involved in this insert, as an SSWSQLFieldCollection"
	
	^self table allFields
]

{ #category : 'output' }
SSWSQLInsertQuery >> parameterisedFields [

	"In the receiver, all fields are parameterised"

	^self fields
]

{ #category : 'output' }
SSWSQLInsertQuery >> values [

	"Return the values to be inserted by the receiver, as an SSWSQLFieldCollection"	

	^self fields collect: [ :field | field accessor valueIn: self object]
]

{ #category : 'output' }
SSWSQLInsertQuery >> writeSQLOn: aStream [

	aStream nextPutAll: 'INSERT INTO '.
	self table writeSQLOn: aStream.
	
	aStream space; nextPut: $(.
	self fields do: [ :field | aStream nextPutIdentifier: field name] separatedBy: [aStream nextPutAll: ', '].

	aStream nextPutAll: ') VALUES ('.
	self values with: self fields do: [ :value :field | value writeSQLOn: aStream forField: field. aStream nextPutAll: ', '].
	aStream 
		position: (aStream position - 2); 
		nextPut: $)

]
