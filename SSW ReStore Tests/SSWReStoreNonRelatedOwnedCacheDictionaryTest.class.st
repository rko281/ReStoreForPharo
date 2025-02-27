"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreNonRelatedOwnedCacheDictionaryTest',
	#superclass : 'SSWReStoreNonRelatedCacheDictionaryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'accessing' }
SSWReStoreNonRelatedOwnedCacheDictionaryTest >> componentDefinition [

	^(Dictionary of: #key -> GenericOwnedTest owner: #owner)
]
