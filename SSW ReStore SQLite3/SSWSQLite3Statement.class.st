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

{ #category : #'initialize-release' }
SSWSQLite3Statement >> cursoredFetch: aBoolean [

	"Always enabled"
]

{ #category : #execution }
SSWSQLite3Statement >> execute [

	^self execute: self values
]

{ #category : #execution }
SSWSQLite3Statement >> execute: bindings [ 

	^(super execute: bindings) asSSWSQLite3ResultSet
]

{ #category : #'connection open/close' }
SSWSQLite3Statement >> free [

	handle isNil ifFalse: [self finalize]
]

{ #category : #accessing }
SSWSQLite3Statement >> parent [

	^connection
]

{ #category : #execution }
SSWSQLite3Statement >> prepare: aString [

	self sqlString: aString.
	^super prepare: aString
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
