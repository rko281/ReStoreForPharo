"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreMultiValueBlockCacheDictionaryTest',
	#superclass : 'SSWReStoreMultiValueCacheDictionaryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreMultiValueBlockCacheDictionaryTest >> componentDefinition [

	^Dictionary of: [ :each | each name first asLowercase asString] -> (OrderedCollection of: GenericOwnedTest dependent)
]
