"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLDeleteQuery,
	#superclass : #SSWSQLConditionalQuery,
	#instVars : [
		'isMultiTableDelete'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #'instance creation' }
SSWSQLDeleteQuery class >> new [

	^super new
		isMultiTableDelete: false;
		yourself
]

{ #category : #testing }
SSWSQLDeleteQuery >> isMultiTableDelete [

	"Answer true if the receiver should delete from all its tables or false if just from the primary (first) table.
	Default is false"

	^isMultiTableDelete
]

{ #category : #accessing }
SSWSQLDeleteQuery >> isMultiTableDelete: anObject [

	isMultiTableDelete := anObject
]

{ #category : #testing }
SSWSQLDeleteQuery >> isWriteQuery [

	^true
]

{ #category : #output }
SSWSQLDeleteQuery >> writeDeletionTablesOn: aStream [

	self isMultiTableDelete
		ifTrue: [self tables do: [ :table | table writeSQLNameOn: aStream] separatedBy: [aStream nextPut: $,]]
		ifFalse: [self tables first writeSQLNameOn: aStream]
]

{ #category : #output }
SSWSQLDeleteQuery >> writeSQLOn: aStream [

	self tables size = 1 
	ifTrue:
		[aStream nextPutAll: 'DELETE FROM '.
		self table writeSQLOn: aStream]
	ifFalse: 
		[aStream dialect supportsDeleteWithJoin 
		ifTrue: 
			[aStream nextPutAll: 'DELETE '.
			self writeDeletionTablesOn: aStream.
			aStream nextPutAll: ' FROM '.
			self tables writeSQLOn: aStream]
		ifFalse: 
			[self error: 'not supported in ', aStream dialect dbmsName]].

	self writeWhereClauseOn: aStream
]
