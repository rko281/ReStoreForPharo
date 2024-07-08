"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLTableCollection',
	#superclass : 'SSWSQLCollection',
	#type : 'variable',
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'output' }
SSWSQLTableCollection >> allFields [

	"Return an SSWLSQLFieldCollection which represents all fields in each of the receiver's tables"
	
	| allFields |
	
	allFields := SSWSQLFieldCollection new: self size.

	self do: [ :table | allFields add: (SSWSQLField allFieldsInTable: table)].
	
	^allFields
]

{ #category : 'accessing' }
SSWSQLTableCollection >> soleTable [

	"Return the single member of the receiver.
	Error if there is not exactly one member"
	
	^self size = 1
		ifTrue: [self first]
		ifFalse: [self error: 'Should be only one table']
]

{ #category : 'accessing' }
SSWSQLTableCollection >> soleTable: anSSWDBTable [

	"Set the single member of the receiver to anSSWDBTable"
	
	self 
		removeAll: self copy;
		add: anSSWDBTable
]

{ #category : 'output' }
SSWSQLTableCollection >> sqlConcatenator [

	"A comma is used to separate a list of tables in SQL"
	
	^', '
]
