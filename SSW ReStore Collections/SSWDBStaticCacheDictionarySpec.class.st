"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBStaticCacheDictionarySpec',
	#superclass : 'SSWDBHashedStaticCollectionSpec',
	#instVars : [
		'keyAccessor'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'actions' }
SSWDBStaticCacheDictionarySpec >> createNonProxiedInstanceFromRow: aDBRow [

	"Overridden to set keyAccessor (issue#0001)"

	^(super createNonProxiedInstanceFromRow: aDBRow)
		keyAccessor: self keyAccessor;
		yourself
]

{ #category : 'constants' }
SSWDBStaticCacheDictionarySpec >> entryClass [
	"Return the class of collection entry appropriate for the receiver"

	^SSWDBCacheDictionaryEntry
]

{ #category : 'accessing' }
SSWDBStaticCacheDictionarySpec >> keyAccessor [

	"keyAccessor stores an a 1-arg block that is evaluated with a targetObject to determine the key at which that object should be stored in the dictionary"

	^keyAccessor
]

{ #category : 'accessing' }
SSWDBStaticCacheDictionarySpec >> keyAccessor: anSSWInstVarAccessor [

	"keyAccessor stores an a 1-arg block that is evaluated with a targetObject to determine the key at which that object should be stored in the dictionary"

	keyAccessor := anSSWInstVarAccessor
]

{ #category : 'accessing' }
SSWDBStaticCacheDictionarySpec >> keyedOn: aSymbolOrBlock [

	"If aSymbolOrBlock is aSymbol it should be an inst var name"

	aSymbolOrBlock isSymbol 
		ifTrue: [self keyAccessor: (SSWInstVarAccessor toAccess: aSymbolOrBlock in: self targetClass)]
		ifFalse: [self keyAccessor: aSymbolOrBlock]
]

{ #category : 'actions' }
SSWDBStaticCacheDictionarySpec >> readAllFor: aCollection [

	"Using a single query (ideally, multiple batched queries if aCollection is too large), read all unrecovered collections specified by the receiver for members of aCollection"

	| untouched ids collections dictionaries |

	untouched := aCollection select: [ :each | (self accessor valueIn: each) isDBProxy].
	untouched isEmpty ifTrue: [^self].

	ids := untouched collect: [ :each | each _idIn: self reStore].
	collections := Dictionary new: untouched size.
	(self readAllEntriesFor: ids) do: [ :each | (collections at: each sourceID ifAbsentPut: [OrderedCollection new]) add: each].
	dictionaries := Dictionary new: collections size.
	collections keysAndValuesDo: 
		[ :id :entries || dict |
		dict := self newCollection.
		entries do: [ :each | dict at: each key put: each target].
		dictionaries at: id put: dict].

	(aCollection reject: [ :each | (self accessor valueIn: each) _isRecovered]) do: 
		[ :proxy |
		(self accessor valueIn: proxy) 
			_proxiedObject: (dictionaries at: proxy _id ifAbsent: [self newCollection]);
			_collectionEntries: (collections at: proxy _id ifAbsent: [OrderedCollection new])]
]
