Class {
	#name : 'SSWDBCacheDictionaryWrapper',
	#superclass : 'Object',
	#instVars : [
		'dictionary',
		'keyAccessor'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'adding' }
SSWDBCacheDictionaryWrapper >> _dbAdd: targetObject [

	"Add the targetObject to the dictionary at the key derived by the keyAccessor"

	^self dictionary at: (self keyAccessor value: targetObject) put: targetObject
]

{ #category : 'adding' }
SSWDBCacheDictionaryWrapper >> _dbAdd: targetObject suggestedIndex: ignore [

	^self _dbAdd: targetObject
]

{ #category : 'restore-internal' }
SSWDBCacheDictionaryWrapper >> _proxifyIn: aCollectionProxy [

	aCollectionProxy _proxiedObject: self dictionary.
	^self dictionary
]

{ #category : 'accessing' }
SSWDBCacheDictionaryWrapper >> dictionary [
	^dictionary
]

{ #category : 'accessing' }
SSWDBCacheDictionaryWrapper >> dictionary: anObject [
	dictionary := anObject
]

{ #category : 'accessing' }
SSWDBCacheDictionaryWrapper >> keyAccessor [
	^keyAccessor
]

{ #category : 'accessing' }
SSWDBCacheDictionaryWrapper >> keyAccessor: anObject [
	keyAccessor := anObject
]
