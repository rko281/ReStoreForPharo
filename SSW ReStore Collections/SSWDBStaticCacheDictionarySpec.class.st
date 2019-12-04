"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBStaticCacheDictionarySpec,
	#superclass : #SSWDBStaticCollectionSpec,
	#instVars : [
		'keyAccessor'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #actions }
SSWDBStaticCacheDictionarySpec >> createNonProxiedInstanceFromRow: aDBRow [

	"Overridden to set keyAccessor (issue#0001)"

	^(super createNonProxiedInstanceFromRow: aDBRow)
		keyAccessor: self keyAccessor;
		yourself
]

{ #category : #constants }
SSWDBStaticCacheDictionarySpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBDictionaryEntry
]

{ #category : #accessing }
SSWDBStaticCacheDictionarySpec >> keyAccessor [

	"keyAccessor stores an SSWInstVarAccessor that accesses the attribute of an object
	that is the key at which that object should be stored in the dictionary"

	^keyAccessor
]

{ #category : #accessing }
SSWDBStaticCacheDictionarySpec >> keyAccessor: anSSWInstVarAccessor [

	"keyAccessor stores an SSWInstVarAccessor that accesses the attribute of an object
	that is the key at which that object should be stored in the dictionary"

	keyAccessor := anSSWInstVarAccessor
]

{ #category : #accessing }
SSWDBStaticCacheDictionarySpec >> keyedOn: aSymbol [

	self keyAccessor: (SSWInstVarAccessor toAccess: aSymbol in: self targetClass)
]
