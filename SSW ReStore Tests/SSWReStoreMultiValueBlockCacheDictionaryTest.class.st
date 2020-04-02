"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreMultiValueBlockCacheDictionaryTest,
	#superclass : #SSWReStoreMultiValueCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreMultiValueBlockCacheDictionaryTest >> componentDefinition [

	^Dictionary of: [ :each | String with: each name first asLowercase] -> (OrderedCollection of: GenericOwnedTest dependent)
]
