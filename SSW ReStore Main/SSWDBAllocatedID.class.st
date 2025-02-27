"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBAllocatedID',
	#superclass : 'Object',
	#instVars : [
		'tableRecord',
		'offset',
		'object'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'converting' }
SSWDBAllocatedID >> asInteger [

	^self id
]

{ #category : 'accessing' }
SSWDBAllocatedID >> id [

	^self nextID + self offset
]

{ #category : 'accessing' }
SSWDBAllocatedID >> nextID [

	"tableRecord should always be a proxy at this point"
	^self tableRecord _proxiedObject nextID
]

{ #category : 'accessing' }
SSWDBAllocatedID >> object [
	^object
]

{ #category : 'accessing' }
SSWDBAllocatedID >> object: anObject [
	object := anObject
]

{ #category : 'accessing' }
SSWDBAllocatedID >> offset [
	^offset
]

{ #category : 'accessing' }
SSWDBAllocatedID >> offset: anObject [
	offset := anObject
]

{ #category : 'operations' }
SSWDBAllocatedID >> postCommit [

	"Update the object with the real ID and update the ReStore cache to match"

	self object _id: self id.

	"object may be a persistent object (in which case immediately post-commit it will be a proxy) or a collection entry (not a proxy and not stored in ReStore cache)"
	self object isDBProxy ifTrue: 
		[(self object _reStore classCacheFor: self object class) 
			at: self object _id put: self object;
			removeKey: self]
]

{ #category : 'accessing' }
SSWDBAllocatedID >> reStoreValue [

	^self id
]

{ #category : 'accessing' }
SSWDBAllocatedID >> tableRecord [
	^tableRecord
]

{ #category : 'accessing' }
SSWDBAllocatedID >> tableRecord: anObject [
	tableRecord := anObject
]

{ #category : 'printing' }
SSWDBAllocatedID >> writeSQLOn: aStream [

	self id writeSQLOn: aStream
]
