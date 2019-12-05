Class {
	#name : #SSWUDBCSQLite3Statement,
	#superclass : #UDBCSQLite3Statement,
	#instVars : [
		'query'
	],
	#category : #'SSW ReStore UDBC SQLite'
}

{ #category : #'public - accessing' }
SSWUDBCSQLite3Statement >> at: aSymbol putAllocatedID: anAllocatedID [

	^self at: aSymbol putInteger: anAllocatedID asInteger
]

{ #category : #'connection open/close' }
SSWUDBCSQLite3Statement >> close [
]

{ #category : #'public - accessing' }
SSWUDBCSQLite3Statement >> dataTypeForObject: anObject [

	(anObject isKindOf: SSWDBAllocatedID) ifTrue: [ ^#at:putAllocatedID: ].
	
	^super dataTypeForObject: anObject
]

{ #category : #'connection open/close' }
SSWUDBCSQLite3Statement >> free [

	handle isNil ifFalse: [self finalize]
]

{ #category : #accessing }
SSWUDBCSQLite3Statement >> query [
	^ query
]

{ #category : #accessing }
SSWUDBCSQLite3Statement >> query: anObject [
	query := anObject
]
