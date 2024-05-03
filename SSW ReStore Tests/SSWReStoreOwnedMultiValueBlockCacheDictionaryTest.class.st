"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreOwnedMultiValueBlockCacheDictionaryTest,
	#superclass : #SSWReStoreOwnedMultiValueCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreOwnedMultiValueBlockCacheDictionaryTest >> componentDefinition [

	^Dictionary of: [ :each | each name first asLowercase asString] -> (OrderedCollection of: GenericOwnedTest dependent) owner: #owner
]
