Class {
	#name : 'SSWDBProxyAndCollectionsSwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'adding' }
SSWDBProxyAndCollectionsSwapper >> addProxy: aProxy forObject: anObject [

	super addProxy: aProxy forObject: anObject.

	aProxy isDBObjectProxy ifTrue: 
		[aProxy _collectionProxies do: 
			[ :each | 
			each _proxiedObject ifNotNil: 
				[ :collection |
				super addProxy: each forObject: collection]]].

	^aProxy
]
