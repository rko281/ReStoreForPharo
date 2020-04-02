"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreOwnedMultiValueBlockCacheDictionaryTest,
	#superclass : #SSWReStoreOwnedMultiValueCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreOwnedMultiValueBlockCacheDictionaryTest >> componentDefinition [

	^Dictionary of: [ :each | String with: each name first asLowercase] -> (OrderedCollection of: GenericOwnedTest dependent) owner: #owner
]
