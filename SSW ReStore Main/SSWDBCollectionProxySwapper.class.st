Class {
	#name : 'SSWDBCollectionProxySwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'actions' }
SSWDBCollectionProxySwapper >> _swap [

	"ASSERT: the receiver contains only collections.
	Swap those collections and their contents in a single run"

	| proxies objects ownerReferencingCollections |

	proxies := OrderedCollection new: proxiesMap size * 10.
	objects := proxies copy.
	ownerReferencingCollections := IdentityDictionary new.

	proxiesMap keysAndValuesDo: 
		[ :collectionProxy :collection || componentProxies collectionOwner |
		collectionProxy _isSwapped ifFalse: 
			[collectionProxy _preSwap.
			collectionOwner := collectionProxy _owner.
			componentProxies := OrderedCollection new.
			collectionProxy _addPersistentComponentsTo: componentProxies.
			componentProxies do: 
				[ :componentProxy | 
				(componentProxy isDBProxy and: [componentProxy _isRecovered and: [componentProxy _isSwapped not]]) ifTrue: 
					[componentProxy _preSwap.
					proxies add: componentProxy.
					objects add: componentProxy _proxiedObject.
					componentProxy == collectionOwner ifTrue: [ownerReferencingCollections at: collectionProxy put: collectionOwner]]].
			proxies add: collectionProxy.
			objects add: collection]].

	"Where a collection contains its owner, the owner's reference to the collection proxy needs to be flipped to the collection so it is correct after the swap"
	ownerReferencingCollections keysAndValuesDo: [ :collectionProxy :ownerProxy | ownerProxy _collectionProxies at: collectionProxy _collectionSpec put: collectionProxy _proxiedObject].

	self swapAll: proxies with: objects.
	objects do: [ :proxy | reStore proxy: proxy forwarded: nil]
]
