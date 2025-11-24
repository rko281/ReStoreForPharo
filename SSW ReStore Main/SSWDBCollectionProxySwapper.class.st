Class {
	#name : 'SSWDBCollectionProxySwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'adding' }
SSWDBCollectionProxySwapper >> addProxy: aProxy forObject: anObject [ 

	super addProxy: aProxy forObject: anObject.
	aProxy isDBCollectionProxy ifTrue: [
		aProxy _addPersistentComponentsTo: self ]
]
