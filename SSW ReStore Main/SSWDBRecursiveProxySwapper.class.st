Class {
	#name : 'SSWDBRecursiveProxySwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'adding' }
SSWDBRecursiveProxySwapper >> addProxy: aProxy forObject: anObject [ 

	(proxiesMap includesKey: aProxy) ifTrue: [ ^ self ].
	super addProxy: aProxy forObject: anObject.
	aProxy _addPersistentComponentsTo: self.
	^ aProxy
]
