"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBDictionaryEntry,
	#superclass : #SSWDBCollectionEntry,
	#instVars : [
		'keyAccessor'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #actions }
SSWDBDictionaryEntry >> addTargetTo: aCollection [

	aCollection directAt: self key put: self target
]

{ #category : #accessing }
SSWDBDictionaryEntry >> key [

	^self keyAccessor valueIn: self target
]

{ #category : #accessing }
SSWDBDictionaryEntry >> keyAccessor [

	"keyAccessor stores an SSWInstVarAccessor that accesses the attribute of targetObject
	that is the key at which that object should be stored in the dictionary"

	^keyAccessor
]

{ #category : #accessing }
SSWDBDictionaryEntry >> keyAccessor: anSSWInstVarAccessor [

	"keyAccessor stores an SSWInstVarAccessor that accesses the attribute of targetObject
	that is the key at which that object should be stored in the dictionary"

	keyAccessor := anSSWInstVarAccessor
]
