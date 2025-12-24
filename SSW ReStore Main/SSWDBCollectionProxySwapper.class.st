Class {
	#name : 'SSWDBCollectionProxySwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'actions' }
SSWDBCollectionProxySwapper >> _swapProxy: aDBProxy [
	"Private - Should only be called inside transactionCritical:"

	self
		initialize: aDBProxy _proxiedObject size + 1;
		addProxy: aDBProxy forObject: aDBProxy _proxiedObject.
	aDBProxy _addPersistentComponentsTo: self.
	self _swap
]
