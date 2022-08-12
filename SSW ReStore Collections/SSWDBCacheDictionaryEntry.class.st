"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBCacheDictionaryEntry,
	#superclass : #SSWDBCollectionEntry,
	#instVars : [
		'keyAccessor'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #private }
SSWDBCacheDictionaryEntry >> _cacheDictionaryKey_ [

	"Special selector allowing interception by the block parser"

	^self key
]

{ #category : #actions }
SSWDBCacheDictionaryEntry >> addTargetTo: aCollection [

	aCollection at: self key put: self target
]

{ #category : #public }
SSWDBCacheDictionaryEntry >> index [

	^self _cacheDictionaryKey_
]

{ #category : #accessing }
SSWDBCacheDictionaryEntry >> key [

	^self keyAccessor value: self target
]

{ #category : #accessing }
SSWDBCacheDictionaryEntry >> keyAccessor [

	"keyAccessor stores an a 1-arg block that is evaluated with a targetObject to determine the key at which that object should be stored in the dictionary"

	^keyAccessor
]

{ #category : #accessing }
SSWDBCacheDictionaryEntry >> keyAccessor: anSSWInstVarAccessor [

	"keyAccessor stores an a 1-arg block that is evaluated with a targetObject to determine the key at which that object should be stored in the dictionary"

	keyAccessor := anSSWInstVarAccessor
]
