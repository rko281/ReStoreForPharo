Class {
	#name : 'SSWSQLite3Statement',
	#superclass : 'SQLite3PreparedStatement',
	#traits : 'SSWReStoreDBStatement',
	#classTraits : 'SSWReStoreDBStatement classTrait',
	#instVars : [
		'values'
	],
	#category : 'SSW ReStore SQLite3',
	#package : 'SSW ReStore SQLite3'
}

{ #category : 'bindings' }
SSWSQLite3Statement >> at: anIndex putUUID: aUUID [

	^self at: anIndex putByteArray: aUUID uuidData
]

{ #category : 'bindings' }
SSWSQLite3Statement >> bindParameters: newBindings [ 

	newBindings keysAndValuesDo: [ :index :value | value sqliteBindTo: self at: index]
]

{ #category : 'initialize-release' }
SSWSQLite3Statement >> cursorType: aSymbol [
]

{ #category : 'execution' }
SSWSQLite3Statement >> execute [

	^self execute: self values
]

{ #category : 'execution' }
SSWSQLite3Statement >> execute: bindings [ 

	^(super execute: bindings) asSSWSQLite3ResultSet
]

{ #category : 'finalization' }
SSWSQLite3Statement >> finalize [
	"Finalize the statement as required by the SQLite3 API. As per the API, the user is expected to finalize a statement after use.

	Since executing a new statement without having finalized the previous one might cause SQLITE_BUSY errors, we can't rely on the garbage collector to execute the finalization, or we'll be exposed to non-deterministic behaviour."

	handle
		ifNotNil:
			[ :hdl |
			 "Remove the statement object from its finalization registry. This should happen before the actual finalization to avoid finalizing the statement twice, which might result in 'undefined and undesirable behavior such as segfaults and heap corruption' as per the SQLite3 API"
			handle := nil.
			hdl manualRelease.
			connection finalize: hdl].
	^ 0
]

{ #category : 'connection open/close' }
SSWSQLite3Statement >> free [

	self finalize
]

{ #category : 'testing' }
SSWSQLite3Statement >> isFreed [

	^handle isNil
]

{ #category : 'accessing' }
SSWSQLite3Statement >> parent [

	^connection
]

{ #category : 'execution' }
SSWSQLite3Statement >> prepare: aString [

	self sqlString: aString.
	^super prepare: aString
]

{ #category : 'accessing' }
SSWSQLite3Statement >> stringAt: aColumn [

	"Convert from UTF8"
	
	^ZnUTF8Encoder default decodeBytes: (self byteArrayAt: aColumn)
]

{ #category : 'accessing' }
SSWSQLite3Statement >> valueAt: anIndex put: anObject [

	self values at: anIndex put: anObject
]

{ #category : 'accessing' }
SSWSQLite3Statement >> valueOfColumn: aColumn [

	| type |

	type := self library apiColumnType: handle atColumn: aColumn.

	type = SQLITE_NULL ifTrue: [^nil].
	type = SQLITE_INTEGER ifTrue: [^self integerAt: aColumn].
	type = SQLITE_TEXT ifTrue: [^self stringAt: aColumn].
	type = SQLITE_FLOAT ifTrue: [^self floatAt: aColumn].
	type = SQLITE_BLOB ifTrue: [^self byteArrayAt: aColumn].

	self error: 'unknown type'
]

{ #category : 'accessing' }
SSWSQLite3Statement >> values [
	^ values ifNil: [ #() ]
]

{ #category : 'accessing' }
SSWSQLite3Statement >> values: anObject [
	values := anObject collect: [  :each | each reStoreValue ]
]
