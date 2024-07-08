"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBOwnedCacheDictionarySpec',
	#superclass : 'SSWDBOwnedCollectionSpec',
	#instVars : [
		'keyAccessor'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'accessing' }
SSWDBOwnedCacheDictionarySpec >> keyAccessor [

	"keyAccessor stores an a 1-arg block that is evaluated with a targetObject to determine the key at which that object should be stored in the dictionary"

	^keyAccessor
]

{ #category : 'accessing' }
SSWDBOwnedCacheDictionarySpec >> keyAccessor: anSSWInstVarAccessor [

	"keyAccessor stores an a 1-arg block that is evaluated with a targetObject to determine the key at which that object should be stored in the dictionary"

	keyAccessor := anSSWInstVarAccessor
]

{ #category : 'accessing' }
SSWDBOwnedCacheDictionarySpec >> keyedOn: aSymbolOrBlock [

	"If aSymbolOrBlock is aSymbol it should be an inst var name"

	aSymbolOrBlock isSymbol 
		ifTrue: [self keyAccessor: (SSWInstVarAccessor toAccess: aSymbolOrBlock in: self targetClass)]
		ifFalse: [self keyAccessor: aSymbolOrBlock]
]

{ #category : 'helpers' }
SSWDBOwnedCacheDictionarySpec >> newCollection [

	^self newCollectionWrapper
		keyAccessor: self keyAccessor;
		dictionary: super newCollection;
		yourself
]

{ #category : 'helpers' }
SSWDBOwnedCacheDictionarySpec >> newCollectionWrapper [

	^SSWDBCacheDictionaryWrapper new
]
