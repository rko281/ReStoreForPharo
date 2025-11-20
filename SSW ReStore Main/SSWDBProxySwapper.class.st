Class {
	#name : 'SSWDBProxySwapper',
	#superclass : 'Object',
	#instVars : [
		'reStore',
		'proxiesMap'
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
		postAction: [ :proxy | proxy _reStore transaction removeUnswappedProxy: proxy]
]

{ #category : 'actions' }
SSWDBProxySwapper >> abandon: aCollection [

	aCollection isEmpty ifFalse: 
		[self reStore: aCollection anyOne _reStore.
		self unswapAll: aCollection]
]

{ #category : 'adding' }
SSWDBProxySwapper >> add: aProxyOrObject [

	^aProxyOrObject isDBProxy 
		ifTrue: [self addProxy: aProxyOrObject]
		ifFalse: [self addObject: aProxyOrObject]
]

{ #category : 'adding' }
SSWDBProxySwapper >> addAll: aCollection [

	proxiesMap isNil ifTrue: [self initialize: aCollection size].

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

	proxiesMap at: aProxy put: anObject.
	^aProxy
]

{ #category : 'initialize-release' }
SSWDBProxySwapper >> initialize: anInteger [

	self initialize.
		
	proxiesMap := IdentityDictionary new: anInteger
]

{ #category : 'testing' }
SSWDBProxySwapper >> isEmpty [

	^proxiesMap isEmpty
]

{ #category : 'enumerating' }
SSWDBProxySwapper >> proxiesDo: aBlock [

	^proxiesMap keysDo: aBlock
]

{ #category : 'accessing' }
SSWDBProxySwapper >> proxiesMap [

	^proxiesMap
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

	| reversedMap |

	reversedMap := IdentityDictionary new: proxiesMap size.
	proxiesMap do: 
		[ :proxy |
		proxy isDBProxy ifTrue:  "<- filter out locally deleted objects"
			[proxy _proxiedObject ifNotNil: [ :object | reversedMap at: proxy put: object]]].
	proxiesMap := reversedMap.

	^reStore ensureHasTransactionCritical: [self _swap]
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
SSWDBProxySwapper >> swapAll: aProxiesCollection with: anObjectsCollection [

	aProxiesCollection do: [ :each | each _preSwapReferences].

	aProxiesCollection asArray elementsExchangeIdentityWith: anObjectsCollection asArray.

	aProxiesCollection with: anObjectsCollection do: 
		[ :object :proxy | "<- arguments reversed following the swap" 
		proxy 
			_setProxiedObject: object;
			_postSwapReferences]
]

{ #category : 'helpers' }
SSWDBProxySwapper >> swapAllWhere: preBlock postAction: postBlock [

	| proxies objects |

	proxies := OrderedCollection new: proxiesMap size.
	objects := OrderedCollection new: proxiesMap size.
	
	proxiesMap keysAndValuesDo: 
		[ :proxy :object |
		(preBlock value: proxy) ifTrue: 
			[proxies add: proxy.
			objects add: object]].

	self swapAll: proxies with: objects.

	objects do: postBlock
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
