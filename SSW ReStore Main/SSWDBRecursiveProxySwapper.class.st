Class {
	#name : 'SSWDBRecursiveProxySwapper',
	#superclass : 'SSWDBProxySwapper',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'adding' }
SSWDBRecursiveProxySwapper >> addAll: aCollection [

	| swapper toAdd |

	swapper := SSWDBProxySwapper newFor: reStore.
	toAdd := aCollection.

	[| preSize |
	preSize := proxiesMap size.
	swapper addAll: toAdd.
	self addSwapper: swapper.
	proxiesMap size > preSize] whileTrue:
		[toAdd := OrderedCollection new: swapper proxiesMap size * 2.
		swapper proxiesDo: [ :each | each _addPersistentComponentsTo: toAdd].
		swapper initialize: toAdd size]
]

{ #category : 'adding' }
SSWDBRecursiveProxySwapper >> addSwapper: aProxySwapper [

	aProxySwapper proxiesMap keysAndValuesDo: 
		[ :proxy :object |
		proxiesMap  at: proxy put: object].

	^aProxySwapper
]
