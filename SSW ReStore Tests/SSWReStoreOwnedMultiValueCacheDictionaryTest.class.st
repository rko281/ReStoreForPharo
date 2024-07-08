"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreOwnedMultiValueCacheDictionaryTest',
	#superclass : 'SSWReStoreMultiValueCacheDictionaryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreOwnedMultiValueCacheDictionaryTest >> componentDefinition [

	^Dictionary of: #key -> (OrderedCollection of: GenericOwnedTest dependent) owner: #owner
]
