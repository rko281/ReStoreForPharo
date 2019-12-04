"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionChange,
	#superclass : #Object,
	#instVars : [
		'affectedEntry'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #'instance creation' }
SSWDBCollectionChange class >> added: anObject [

	^self newWithEntry:
		(SSWDBCollectionEntry new
			target: anObject;
			yourself)
]

{ #category : #'instance creation' }
SSWDBCollectionChange class >> newWithEntry: anSSWDBCollectionEntry [

	^self new
		affectedEntry: anSSWDBCollectionEntry;
		yourself
]

{ #category : #accessing }
SSWDBCollectionChange >> affectedEntry [

	"affectedEntry stores the Collection Entry affected (added/removed/altered) by the
	change represented by the receiver"
	
	^affectedEntry
]

{ #category : #accessing }
SSWDBCollectionChange >> affectedEntry: anSSWDBCollectionEntry [

	"affectedEntry stores the Collection Entry affected (added/removed/altered) by the
	change represented by the receiver"
	
	affectedEntry := anSSWDBCollectionEntry
]

{ #category : #actions }
SSWDBCollectionChange >> applyTo: aCollectionOfEntries [

	"Apply the change represented by the receiver to the given collection
	of collectionEntries"
	
	self subclassResponsibility
]

{ #category : #testing }
SSWDBCollectionChange >> canRemoveKey [

	"Return a Boolean indicating whether the receiver can potentially remove a key/index from a collection.
	Default - false"

	^false
]

{ #category : #testing }
SSWDBCollectionChange >> canRemoveValue [

	"Return a Boolean indicating whether the receiver can potentially remove a value object from a collection.
	Default - false"

	^false
]

{ #category : #actions }
SSWDBCollectionChange >> commitFor: aCollectionProxy [

	"Apply the change represented by the receiver onto the ReStore in which
	the given SSWDBCollectionProxy resides"
	
	self subclassResponsibility
]

{ #category : #actions }
SSWDBCollectionChange >> prepareToCommitFor: anSSWDBCachingCollectionProxy [

	^self affectedEntry prepareToCommitFor: anSSWDBCachingCollectionProxy
]
