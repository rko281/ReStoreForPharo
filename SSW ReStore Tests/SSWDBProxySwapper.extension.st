Extension { #name : 'SSWDBProxySwapper' }

{ #category : '*SSW ReStore Tests' }
SSWDBProxySwapper >> swapAllWhere: preBlock postActionWithCount: postBlock [

	| swapProxies swapObjects immutables |

	swapProxies := OrderedCollection new: proxies size.
	swapObjects := swapProxies copy.
	immutables := swapProxies copy.

	proxies with: objects do: [ :proxy :object |
		(preBlock value: proxy) ifTrue: [
			proxy _preSwapReferences.
			swapProxies add: proxy.
			swapObjects add: object.
			object isImmutable ifTrue: [ object isImmutable: false. immutables add: object ]. ] ].

	SSWReStoreProxySwapperTest incrementSwapCount: swapProxies size.
	swapProxies asArray elementsExchangeIdentityWith: swapObjects asArray.

	swapProxies
		with: swapObjects
		do: [ :object :proxy | "<- arguments reversed following the swap"
			proxy
				_setProxiedObject: object;
				_postSwapReferences.
			postBlock value: proxy ].
		
	immutables do: [  :each | each _proxiedObject isImmutable: true ]
]
