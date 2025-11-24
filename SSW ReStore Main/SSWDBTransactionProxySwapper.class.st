Class {
	#name : 'SSWDBTransactionProxySwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'operations' }
SSWDBTransactionProxySwapper class >> swapAll: aCollection [

	"Equivalent to
		aCollection collect: [ :each | each _swap] 
	"

	^aCollection isEmpty 
		ifTrue: [aCollection]
		ifFalse: [(self newFor: aCollection anyOne _reStore) swapAll: aCollection]
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper class >> unswapAll: aCollection [

	"Equivalent to
		aCollection collect: [ :each | each _unswap] 
	"

	^aCollection isEmpty 
		ifTrue: [aCollection]
		ifFalse: [(self newFor: aCollection anyOne _reStore) unswapAll: aCollection]
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper >> swapAll: aCollectionOfProxies [

	| proxies objects unrecovered |

	proxies := OrderedCollection new: aCollectionOfProxies size.
	objects := OrderedCollection new: aCollectionOfProxies size.
	unrecovered := OrderedCollection new.
	aCollectionOfProxies do: 
		[ :each | 
		each _preSwap.
		each _proxiedObject 
			ifNil: [unrecovered add: each]
			ifNotNil: [ :object | proxies add: each. objects add: object]].

	self swapAll: proxies with: objects.

	^(aCollectionOfProxies species new: aCollectionOfProxies size) 
		addAll: objects; "now proxies"
		addAll: unrecovered;
		yourself
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper >> unswapAll: aCollectionOfProxies [

	| proxies objects unrecovered |

	proxies := OrderedCollection new: aCollectionOfProxies size.
	objects := OrderedCollection new: aCollectionOfProxies size.
	unrecovered := OrderedCollection new.
	aCollectionOfProxies do: 
		[ :each | 
		each _preUnswap.
		each _proxiedObject 
			ifNil: [unrecovered add: each]
			ifNotNil: [ :object | proxies add: each. objects add: object]].

	self swapAll: proxies with: objects.

	^(aCollectionOfProxies species new: aCollectionOfProxies size) 
		addAll: objects; "now proxies"
		addAll: unrecovered;
		yourself
]
