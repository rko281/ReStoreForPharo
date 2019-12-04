"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionRemoval,
	#superclass : #SSWDBCollectionChange,
	#category : #'SSW ReStore Collections'
}

{ #category : #actions }
SSWDBCollectionRemoval >> applyTo: aCollection [

	self affectedEntry removeFrom: aCollection
]

{ #category : #testing }
SSWDBCollectionRemoval >> canRemoveKey [

	^true
]

{ #category : #testing }
SSWDBCollectionRemoval >> canRemoveValue [

	^true
]

{ #category : #'actions - api' }
SSWDBCollectionRemoval >> commitFor: aCollectionProxy [

	self affectedEntry isPersistent ifTrue: 
		[aCollectionProxy _collectionSpec deleteEntry: self affectedEntry in: aCollectionProxy _reStore]
]
