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
SSWDBTransactionProxySwapper >> _abandon [

	self 
		swapAllWhere: [ :proxy | proxy _isPersistent ifTrue: [proxy _preUnswap. true] ifFalse: [false]]
		postAction: [ :proxy | "ASSERT: We are removing everything from #currentReferencedObjects, so we don't need to remove one by one"
			 ].
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper >> _swap [
	"Override to not skip proxies already in the desired state--this should never happen in the transaction mechanism."

	self
		swapAllWhere: [ :proxy | proxy _preSwap. true ]
		postAction: [ :proxy | proxy _reStore addToTransaction: proxy ].
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper >> _unswap [
	"Override to not skip proxies already in the desired state--this should never happen in the transaction mechanism."

	self
		swapAllWhere: [ :proxy | proxy _preUnswap. true ]
		postAction: [ :proxy | "ASSERT: We are removing everything from #currentReferencedObjects, so we don't need to remove one by one"
			 ].
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper >> abandon: aCollection [

	aCollection isEmpty ifFalse: 
		[self reStore: aCollection anyOne _reStore.
		self 
			initialize: aCollection size;
			addAll: aCollection;
			_abandon]
]

{ #category : 'operations' }
SSWDBTransactionProxySwapper >> addProxy: aProxy [

	self assert: aProxy _isRecovered.
	"We are used internal to the transaction mechanism,
	so must be willing to swap proxies that are not yet persistent, i.e. about to be stored."
	^ self addProxy: aProxy forObject: aProxy _proxiedObject
]
