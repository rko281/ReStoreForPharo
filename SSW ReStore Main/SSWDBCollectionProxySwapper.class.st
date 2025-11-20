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

	| proxies objects |

	proxies := OrderedCollection new: proxiesMap size * 10.
	objects := proxies copy.

	proxiesMap keysAndValuesDo: 
		[ :collectionProxy :collection || componentProxies |
		collectionProxy _isSwapped ifFalse: 
			[collectionProxy _preSwap.
			componentProxies := OrderedCollection new.
			collectionProxy _addPersistentComponentsTo: componentProxies.
			componentProxies do: 
				[ :componentProxy | 
				(componentProxy isDBProxy and: [componentProxy _isRecovered and: [componentProxy _isSwapped not]]) ifTrue: 
					[componentProxy _preSwap.
					proxies add: componentProxy.
					objects add: componentProxy _proxiedObject]].
			proxies add: collectionProxy.
			objects add: collection]].

	self swapAll: proxies with: objects.
	objects do: [ :proxy | reStore addToTransaction: proxy]
]
