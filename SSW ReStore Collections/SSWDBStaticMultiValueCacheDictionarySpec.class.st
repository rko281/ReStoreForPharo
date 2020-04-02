Class {
	#name : #SSWDBStaticMultiValueCacheDictionarySpec,
	#superclass : #SSWDBStaticCacheDictionarySpec,
	#category : #'SSW ReStore Collections'
}

{ #category : #constants }
SSWDBStaticMultiValueCacheDictionarySpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBMultiValueCacheDictionaryEntry
]

{ #category : #actions }
SSWDBStaticMultiValueCacheDictionarySpec >> readAllFor: aCollection [

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
		entries do: [ :each | (dict at: each key ifAbsentPut: [OrderedCollection new]) add: each target].
		dictionaries at: id put: dict].

	(aCollection reject: [ :each | (self accessor valueIn: each) _isRecovered]) do: 
		[ :proxy |
		(self accessor valueIn: proxy) 
			_proxiedObject: (dictionaries at: proxy _id ifAbsent: [self newCollection]);
			_collectionEntries: (collections at: proxy _id ifAbsent: [OrderedCollection new])]
]
