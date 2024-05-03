"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBStaticMultiValueCacheDictionarySpec,
	#superclass : #SSWDBStaticCacheDictionarySpec,
	#category : #'SSW ReStore Collections'
}

{ #category : #'change detection' }
SSWDBStaticMultiValueCacheDictionarySpec >> allAdditionsTo: aCollection [

	"Return an collection of SSWDBCollectionAdditions representing the addition of all aCollection's elements to itself, starting when empty"

	| additions |

	additions := OrderedCollection new: aCollection size.

	aCollection keysAndValuesDo: [ :key :values | values do: [ :each | additions add: (SSWDBCollectionAddition added: each at: key)]].

	^additions
]

{ #category : #'change detection' }
SSWDBStaticMultiValueCacheDictionarySpec >> changesTo: aCollection from: aCollectionOfEntries comparisonSetClass: aSetClass [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries."

	| allValues changes |

	allValues := aCollection inject: (aSetClass new: aCollection size * 4) into: [ :all :values | all addAll: values; yourself].
	changes := OrderedCollection new.

	aCollectionOfEntries do: 
		[ :entry |
		((aCollection at: entry key ifAbsent: [#()]) includes: entry target) 
			ifTrue: [allValues remove: entry target]
			ifFalse: [changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	allValues do: [ :each | changes add: (SSWDBCollectionAddition added: each)].

	^changes
]

{ #category : #constants }
SSWDBStaticMultiValueCacheDictionarySpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBMultiValueCacheDictionaryEntry
]

{ #category : #'change detection' }
SSWDBStaticMultiValueCacheDictionarySpec >> equalityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via equality (=)"

	^self changesTo: aCollection from: aCollectionOfEntries comparisonSetClass: Set
]

{ #category : #'change detection' }
SSWDBStaticMultiValueCacheDictionarySpec >> identityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via identity (==)"

	^self changesTo: aCollection from: aCollectionOfEntries comparisonSetClass: IdentitySet
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
