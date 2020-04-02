"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRelatedKeyDictionaryTest,
	#superclass : #SSWReStoreRelatedDictionaryTest,
	#instVars : [
		'inverseDictionary'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedKeyDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest related -> GenericOwnedTest)
]

{ #category : #public }
SSWReStoreRelatedKeyDictionaryTest >> fetchTestObjects [

	super fetchTestObjects.

	inverseDictionary := IdentityDictionary new.

	testObject component keysAndValuesDo: [ :eachKey :eachValue | inverseDictionary at: eachValue put: eachKey]
]
