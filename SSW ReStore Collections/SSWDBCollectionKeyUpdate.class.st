Class {
	#name : #SSWDBCollectionKeyUpdate,
	#superclass : #SSWDBCollectionIndexUpdate,
	#category : #'SSW ReStore Collections'
}

{ #category : #'actions - api' }
SSWDBCollectionKeyUpdate >> prepareToCommitFor: anSSWDBCollectionProxy [

	(anSSWDBCollectionProxy _shouldUnstoreKey: self affectedEntry index) ifTrue: [self affectedEntry index unstore].

	^super prepareToCommitFor: anSSWDBCollectionProxy
]
