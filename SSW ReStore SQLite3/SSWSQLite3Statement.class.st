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

{ #category : #bindings }
SSWSQLite3Statement >> at: anIndex putUUID: aUUID [

	^self at: anIndex putByteArray: (ByteArray withAll: aUUID)
]

{ #category : #'initialize-release' }
SSWSQLite3Statement >> cursoredFetch: aBoolean [

	"Always enabled"
]

{ #category : #bindings }
SSWSQLite3Statement >> dataTypeForObject: anObject [	
	
	| typeSelector |
	typeSelector := super dataTypeForObject: anObject. 

	^(typeSelector = #at:putByteArray: and: [ anObject isKindOf: UUID])
		ifTrue: [ #at:putUUID: ]
		ifFalse: [ typeSelector ]
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

	"It appears statements can raise errors when being free'd so add an error check for the case seen in test runs - a statement which previously raised a constraint violation raises it again when free'd"
	handle isNil ifFalse: [[self finalize] on: SQLite3ConstraintViolation do: [ :exc | exc return]]
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
SSWSQLite3Statement >> stringAt: aColumn [

	"Convert from UTF8"
	
	^ZnUTF8Encoder default decodeBytes: (self byteArrayAt: aColumn)
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
