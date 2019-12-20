Class {
	#name : #SSWSQLite3Statement,
	#superclass : #SQLite3PreparedStatement,
	#traits : 'SSWReStoreDBStatement',
	#classTraits : 'SSWReStoreDBStatement classTrait',
	#instVars : [
		'values'
	],
	#category : #'SSW ReStore SQLite3'
}

{ #category : #execution }
SSWSQLite3Statement >> execute [

	results isNil ifFalse: 
		[ self clearBindings; reset.
		results := nil ].

	^(SSWSQLite3ResultSet new statement: self) execute
]

{ #category : #'connection open/close' }
SSWSQLite3Statement >> free [

	handle isNil ifFalse: [self finalize]
]

{ #category : #accessing }
SSWSQLite3Statement >> parent [

	^connection
]

{ #category : #accessing }
SSWSQLite3Statement >> valueAt: anIndex put: anObject [

	self values at: anIndex put: anObject
]

{ #category : #accessing }
SSWSQLite3Statement >> values [
	^ values ifNil: [ #() ]
]

{ #category : #accessing }
SSWSQLite3Statement >> values: anObject [
	values := anObject collect: [  :each | each reStoreValue ]
]
