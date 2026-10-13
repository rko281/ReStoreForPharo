Class {
	#name : 'SSWDBProxySwapper',
	#superclass : 'Object',
	#instVars : [
		'reStore',
		'proxies',
		'objects'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'instance creation' }
SSWDBProxySwapper class >> newFor: aReStore [

	^self new
		reStore: aReStore;
		yourself
]

{ #category : 'actions' }
SSWDBProxySwapper >> _swap [

	self 
		swapAllWhere: [ :proxy | proxy _isSwapped ifTrue: [false] ifFalse: [proxy _preSwap. true]]
		postAction: [ :proxy | proxy _reStore addToTransaction: proxy]
]

{ #category : 'actions' }
SSWDBProxySwapper >> _swapProxy: aDBProxy [

	"Private - Should only be called inside transactionCritical:"

	self 
		initialize: 3;
		addProxy: aDBProxy forObject: aDBProxy _proxiedObject;
		_swap
]

{ #category : 'actions' }
SSWDBProxySwapper >> _unswap [

	self 
		swapAllWhere: [ :proxy | proxy _isSwapped ifTrue: [proxy _preUnswap. true] ifFalse: [false]]
		postAction: [ :proxy | proxy _reStore removeFromTransaction: proxy]
]

{ #category : 'adding' }
SSWDBProxySwapper >> add: aProxyOrObject [

	^aProxyOrObject isDBProxy 
		ifTrue: [self addProxy: aProxyOrObject]
		ifFalse: [self addObject: aProxyOrObject]
]

{ #category : 'adding' }
SSWDBProxySwapper >> addAll: aCollection [

	proxies isNil ifTrue: [self initialize: aCollection size].

	^aCollection do: [ :each | self add: each]
]

{ #category : 'adding' }
SSWDBProxySwapper >> addObject: anObject [

	^(anObject _dbProxyIn: reStore ifNone: [nil]) ifNotNil: [ :proxy | self addProxy: proxy forObject: anObject]
]

{ #category : 'adding' }
SSWDBProxySwapper >> addProxy: aDBProxy [

	^aDBProxy _isPersistent ifTrue: 
		[aDBProxy _proxiedObject ifNotNil: 
			[ :object |
			self addProxy: aDBProxy forObject: object]]
]

{ #category : 'adding' }
SSWDBProxySwapper >> addProxy: aProxy forObject: anObject [

	proxies addLast: aProxy.
	objects addLast: anObject.
	^aProxy
]

{ #category : 'initialize-release' }
SSWDBProxySwapper >> initialize: anInteger [

	self initialize.
		
	"Use a parallel pair of OrderedCollections to record proxies and their objects to be swapped.
	This is more performant than the previous IdentityDictionary implementation but does not prevent duplicate additions.
	Subclasses must therefore be tolerant of potential duplicates (e.g. via checks in the swapAllWhere: block) 
	or their client code must not introduce them"
	proxies := OrderedCollection new: anInteger.
	objects := OrderedCollection new: anInteger
]

{ #category : 'testing' }
SSWDBProxySwapper >> isEmpty [

	^proxies isEmpty
]

{ #category : 'enumerating' }
SSWDBProxySwapper >> proxiesDo: aBlock [

	^proxies do: aBlock
]

{ #category : 'accessing' }
SSWDBProxySwapper >> reStore [
	^reStore
]

{ #category : 'accessing' }
SSWDBProxySwapper >> reStore: anObject [
	reStore := anObject
]

{ #category : 'operations' }
SSWDBProxySwapper >> reswap [

	"ASSERT: the transaction in which the receiver was created has been rolled back.
	Reverse the map to reflect that a swap has previously occurred then reswap objects back into place"

	^reStore ensureHasTransactionCritical: [
		| reversedProxies reversedObjects |

		reversedProxies := OrderedCollection new: proxies size.
		reversedObjects := reversedProxies copy.
		objects do: 
			[ :proxy |
			proxy isDBProxy ifTrue:  "<- filter out locally deleted objects"
				[proxy _proxiedObject ifNotNil: 
					[ :object | .
					reversedProxies addLast: proxy.
					reversedObjects addLast: object ]]].
		proxies := reversedProxies.
		objects := reversedObjects.

		self _swap]
]

{ #category : 'operations' }
SSWDBProxySwapper >> swap [

	reStore ensureHasTransactionCritical: [self _swap]
]

{ #category : 'operations' }
SSWDBProxySwapper >> swapAll: aCollection [

	reStore ensureHasTransactionCritical: 
		[self 
			initialize: aCollection size;
			addAll: aCollection;
			_swap]
]

{ #category : 'helpers' }
SSWDBProxySwapper >> swapAllWhere: preBlock postAction: postBlock [

	| swapProxies swapObjects |

	swapProxies := OrderedCollection new: proxies size.
	swapObjects := swapProxies copy.

	proxies with: objects do: [ :proxy :object |
		(preBlock value: proxy) ifTrue: [
			proxy _preSwapReferences.
			swapProxies add: proxy.
			swapObjects add: object ] ].

	swapProxies asArray elementsExchangeIdentityWith: swapObjects asArray.

	swapProxies
		with: swapObjects
		do: [ :object :proxy | "<- arguments reversed following the swap"
			proxy
				_setProxiedObject: object;
				_postSwapReferences.
			postBlock value: proxy ]
]

{ #category : 'operations' }
SSWDBProxySwapper >> unswap [

	reStore transactionCritical: [self _unswap]
]

{ #category : 'operations' }
SSWDBProxySwapper >> unswapAll: aCollection [

	reStore transactionCritical: 
		[self 
			initialize: aCollection size;
			addAll: aCollection;
			_unswap]
]
