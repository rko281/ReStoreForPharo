Class {
	#name : #SSWSQLite3Statement,
	#superclass : #SQLite3PreparedStatement,
	#instVars : [
		'query'
	],
	#category : #'SSW ReStore SQLite3'
}

{ #category : #'public - accessing' }
SSWSQLite3Statement >> at: aSymbol putAllocatedID: anAllocatedID [

	^self at: aSymbol putInteger: anAllocatedID asInteger
]

{ #category : #'connection open/close' }
SSWSQLite3Statement >> close [
]

{ #category : #'public - accessing' }
SSWSQLite3Statement >> dataTypeForObject: anObject [

	(anObject isKindOf: SSWDBAllocatedID) ifTrue: [ ^#at:putAllocatedID: ].
	
	^super dataTypeForObject: anObject
]

{ #category : #'connection open/close' }
SSWSQLite3Statement >> free [

	handle isNil ifFalse: [self finalize]
]

{ #category : #accessing }
SSWSQLite3Statement >> query [
	^ query
]

{ #category : #accessing }
SSWSQLite3Statement >> query: anObject [
	query := anObject
]
