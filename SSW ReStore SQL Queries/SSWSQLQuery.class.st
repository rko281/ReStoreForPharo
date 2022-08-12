"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLQuery,
	#superclass : #Object,
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #converting }
SSWSQLQuery >> asSubQuery [

	^SSWSQLSubQuery new
		query: self;
		yourself
]

{ #category : #testing }
SSWSQLQuery >> isReadQuery [

	"Subclasses should override if they read data"
	
	^false
]

{ #category : #testing }
SSWSQLQuery >> isWriteQuery [

	"Subclasses should override if they write data"
	
	^false
]

{ #category : #operations }
SSWSQLQuery >> preExecIn: anSSWReStore [
]

{ #category : #testing }
SSWSQLQuery >> sqlCanBeParameterized [

	^false
]
