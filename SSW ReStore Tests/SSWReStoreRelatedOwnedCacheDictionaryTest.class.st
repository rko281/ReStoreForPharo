"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRelatedOwnedCacheDictionaryTest,
	#superclass : #SSWReStoreRelatedCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedOwnedCacheDictionaryTest >> componentDefinition [

	^(Dictionary of: #key -> GenericOwnedTest related owner: #owner)
]
