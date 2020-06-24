"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreOwnedBlockCacheDictionaryTest,
	#superclass : #SSWReStoreOwnedCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreOwnedBlockCacheDictionaryTest >> componentDefinition [

	^Dictionary of: [ :each | each name first asLowercase asString] -> GenericOwnedTest dependent owner: #owner
]
