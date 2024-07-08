"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBCollectionRemoval',
	#superclass : 'SSWDBCollectionChange',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'actions' }
SSWDBCollectionRemoval >> applyTo: aCollection [

	self affectedEntry removeFrom: aCollection
]

{ #category : 'actions - api' }
SSWDBCollectionRemoval >> commitFor: aCollectionProxy [

	self affectedEntry isPersistent ifTrue: [aCollectionProxy _collectionSpec deleteEntry: self affectedEntry]
]

{ #category : 'actions - api' }
SSWDBCollectionRemoval >> prepareToCommitFor: anSSWDBCollectionProxy [

	(anSSWDBCollectionProxy _shouldUnstoreValue: self affectedEntry target) ifTrue: [self affectedEntry target unstore].

	^super prepareToCommitFor: anSSWDBCollectionProxy
]
