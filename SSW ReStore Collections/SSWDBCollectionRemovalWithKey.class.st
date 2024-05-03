Class {
	#name : #SSWDBCollectionRemovalWithKey,
	#superclass : #SSWDBCollectionRemoval,
	#category : #'SSW ReStore Collections'
}

{ #category : #'actions - api' }
SSWDBCollectionRemovalWithKey >> prepareToCommitFor: anSSWDBCollectionProxy [

	(anSSWDBCollectionProxy _shouldUnstoreKey: self affectedEntry index) ifTrue: [self affectedEntry index unstore].

	^super prepareToCommitFor: anSSWDBCollectionProxy
]
