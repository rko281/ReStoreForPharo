"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLSubQuery,
	#superclass : #SSWSQLQuery,
	#instVars : [
		'query'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #testing }
SSWSQLSubQuery >> isEmpty [

	"Collection behavior"

	^false
]

{ #category : #testing }
SSWSQLSubQuery >> isReadQuery [
	
	^self query isReadQuery
]

{ #category : #testing }
SSWSQLSubQuery >> isWriteQuery [
	
	^self query isWriteQuery
]

{ #category : #accessing }
SSWSQLSubQuery >> occurrencesOf: anObject [

	^anObject = SSWSQLQueryParameter
		ifTrue: [self query parameterisedFields size]
		ifFalse: [super occurrencesOf: anObject "force MNU"]
]

{ #category : #operations }
SSWSQLSubQuery >> preExecIn: anSSWReStore [

	self query preExecIn: anSSWReStore
]

{ #category : #accessing }
SSWSQLSubQuery >> query [
	^query
]

{ #category : #accessing }
SSWSQLSubQuery >> query: anObject [
	query := anObject
]

{ #category : #output }
SSWSQLSubQuery >> writeSQLOn: aStream [

	"SubQueries should we wrapped in parentheses"

	aStream nextPut: $(.
	self query writeSQLOn: aStream.
	aStream nextPut: $)

]
