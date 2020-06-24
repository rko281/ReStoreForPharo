"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreBlockCacheDictionaryTest,
	#superclass : #SSWReStoreCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreBlockCacheDictionaryTest >> componentDefinition [

	^Dictionary of: [ :each | each name first asLowercase asString] -> GenericOwnedTest dependent
]
