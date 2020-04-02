"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreOwnedCacheDictionaryTest,
	#superclass : #SSWReStoreCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreOwnedCacheDictionaryTest >> componentDefinition [

	^Dictionary of: #key -> GenericOwnedTest dependent owner: #owner
]
