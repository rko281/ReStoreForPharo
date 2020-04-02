Class {
	#name : #SSWDBMultiValueCacheDictionaryWrapper,
	#superclass : #SSWDBCacheDictionaryWrapper,
	#category : #'SSW ReStore Collections'
}

{ #category : #adding }
SSWDBMultiValueCacheDictionaryWrapper >> _dbAdd: targetObject [

	"Add the targetObject to the dictionary at the key derived by the keyAccessor"

	^(self dictionary at: (self keyAccessor value: targetObject) ifAbsentPut: [OrderedCollection new]) add: targetObject
]
