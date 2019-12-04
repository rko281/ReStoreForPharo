"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionObjectRemoval,
	#superclass : #Object,
	#instVars : [
		'removedObject'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #'instance creation' }
SSWDBCollectionObjectRemoval class >> newWithObject: anObject [

	^super new
		removedObject: anObject;
		yourself
]

{ #category : #actions }
SSWDBCollectionObjectRemoval >> applyTo: aCollection [

	"No action (the receiver is polymorphic with SSWDBCollectionChange)"
	
	^self
]

{ #category : #testing }
SSWDBCollectionObjectRemoval >> canRemoveKey [

	"No (the receiver is polymorphic with SSWDBCollectionChange)"

	^false
]

{ #category : #testing }
SSWDBCollectionObjectRemoval >> canRemoveValue [

	"No (the receiver is polymorphic with SSWDBCollectionChange)"

	^false
]

{ #category : #actions }
SSWDBCollectionObjectRemoval >> commitFor: aCollection [

	"No action (the receiver is polymorphic with SSWDBCollectionChange)"
	
	^self
]

{ #category : #actions }
SSWDBCollectionObjectRemoval >> prepareToCommitFor: aCollectionProxy [

	"Unstore the removedObject"

	self removedObject unstore
]

{ #category : #accessing }
SSWDBCollectionObjectRemoval >> removedObject [

	"removedObject stores an Object (value) completely removed from a Collection.
	The receiver represents the complete removal of this object"

	^removedObject
]

{ #category : #accessing }
SSWDBCollectionObjectRemoval >> removedObject: anObject [

	"removedObject stores an Object (value) completely removed from a Collection.
	The receiver represents the complete removal of this object"

	removedObject := anObject
]
