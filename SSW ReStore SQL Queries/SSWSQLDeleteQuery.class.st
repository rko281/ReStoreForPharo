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

	aStream nextPutAll: 'DELETE FROM '.
	self table writeSQLOn: aStream.

	self writeWhereClauseOn: aStream
]
