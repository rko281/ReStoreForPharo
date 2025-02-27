"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLDeleteObjectQuery',
	#superclass : 'SSWSQLObjectQuery',
	#category : 'SSW ReStore SQL Queries',
	#package : 'SSW ReStore SQL Queries'
}

{ #category : 'accessing' }
SSWSQLDeleteObjectQuery >> parameterisedFields [

	^{self table idField}
]

{ #category : 'accessing' }
SSWSQLDeleteObjectQuery >> values [

	^{self object _id}
]

{ #category : 'output' }
SSWSQLDeleteObjectQuery >> writeSQLOn: aStream [

	aStream nextPutAll: 'DELETE FROM '.
	self table writeSQLOn: aStream.
	
	aStream nextPutAll: ' WHERE '.
	self objectIDCondition writeSQLOn: aStream
]
