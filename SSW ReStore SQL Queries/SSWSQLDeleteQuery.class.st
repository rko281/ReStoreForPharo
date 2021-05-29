"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLDeleteQuery,
	#superclass : #SSWSQLConditionalQuery,
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #testing }
SSWSQLDeleteQuery >> isWriteQuery [

	^true
]

{ #category : #output }
SSWSQLDeleteQuery >> writeSQLOn: aStream [

	self tables size = 1
	ifTrue: 
		[aStream nextPutAll: 'DELETE FROM '.
		self table writeSQLOn: aStream]
	ifFalse: 
		[aStream nextPutAll: 'DELETE '.
		self tables do: [ :table | table writeSQLNameOn: aStream] separatedBy: [aStream nextPut: $,].
		aStream nextPutAll: ' FROM '.
		self tables writeSQLOn: aStream].

	self writeWhereClauseOn: aStream
]
