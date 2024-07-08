"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBCollectionUpdate',
	#superclass : 'SSWDBCollectionChange',
	#instVars : [
		'newTarget'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'instance creation' }
SSWDBCollectionUpdate class >> entry: aCollectionEntry newTarget: anObject [

	^(self newWithEntry: aCollectionEntry)
		newTarget: anObject;
		yourself
]

{ #category : 'actions - api' }
SSWDBCollectionUpdate >> applyTo: aCollection [

	self affectedEntry target: self newTarget
]

{ #category : 'actions - api' }
SSWDBCollectionUpdate >> commitFor: aCollectionProxy [

	self affectedEntry isPersistent ifTrue: 
		[aCollectionProxy _collectionSpec 
			updateEntry: self affectedEntry 
			withTarget: self newTarget
			in: aCollectionProxy _reStore]
]

{ #category : 'accessing' }
SSWDBCollectionUpdate >> newTarget [

	"newTarget stores the object which is now in the position of the collection
	associated with the receiver's entry"

	^newTarget
]

{ #category : 'accessing' }
SSWDBCollectionUpdate >> newTarget: anObject [

	"newTarget stores the object which is now in the position of the collection
	associated with the receiver's entry"

	newTarget := anObject
]

{ #category : 'actions - api' }
SSWDBCollectionUpdate >> prepareToCommitFor: anSSWDBCollectionProxy [

	(anSSWDBCollectionProxy _shouldUnstoreValue: self affectedEntry target) ifTrue: [self affectedEntry target unstore].
	self newTarget _ensureActiveIn: anSSWDBCollectionProxy _reStore.

	^super prepareToCommitFor: anSSWDBCollectionProxy
]
