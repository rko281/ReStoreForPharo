Extension { #name : #Dictionary }

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _changesFrom: aCollectionOfEntries [

	"Override to include key information if necessary. 
	This can be determined from any member of aCollectionOfEntries.
	Defer to _collectionAdditions if empty (to give keyed entries, issue#0026) "

	^aCollectionOfEntries isEmpty 
	ifTrue:
		[self _collectionAdditions]
	ifFalse:
		[(aCollectionOfEntries first isKindOf: SSWDBDictionaryEntry)
			ifTrue: [super _changesFrom: aCollectionOfEntries]
			ifFalse: [self _keyedChangesFrom: aCollectionOfEntries]]
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _collectionAdditions [

	"Override to include key information"

	^self _keyedCollectionAdditions
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _keyRemovalsIn: aCollectionOfChanges [

	^(aCollectionOfChanges isEmpty or: [aCollectionOfChanges first affectedEntry isKindOf: SSWDBDictionaryEntry])
	ifTrue:
		[#()]
	ifFalse:
		[aCollectionOfChanges
			select: [ :change | change canRemoveKey and: [(self includesKey: change affectedEntry index) not]]
			thenCollect: [ :change | SSWDBCollectionObjectRemoval newWithObject: change affectedEntry index]]
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _valuesRemovedBy: aCollectionOfChanges [

	"The receiver is not a set (i.e. allows duplicates) and so cannot take advantage of superclass optimisation"

	^self _superValuesRemovedBy: aCollectionOfChanges
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> directAdd: targetObject suggestedIndex: keyObject [

	"Make the receiver polymorphic with an indexed collection (key=index)"

	^self directAt: keyObject put: targetObject

]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> directAt: aKey put: anObject [

	^self at: aKey put: anObject
]

{ #category : #'*SSW ReStore Collections' }
Dictionary class >> of: targetClass keyClass: keyClass [

	"ReStore specification method - create and return an appropriate SSWDBCollectionSpec"

	^self new of: targetClass keyClass: keyClass
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: targetClass keyClass: keyClass [

	"ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The Dictionary's keys will be of the class keyClass, which should be a valid persistent class.
	Create and return an appropriate SSWDBCollectionSpec"

	^(self of: targetClass specClass: SSWDBStaticDictionarySpec)
		setKeyClass: keyClass;
		yourself
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: targetClass keyedOn: aSymbol [

	"ReStore specification method - specify a Dictionary which stores instances of targetClass.
	Instances are stored in the receiver at: the value of their instance variable named aSymbol.
	Create and return an appropriate SSWDBCollectionSpec"

	^(self of: targetClass specClass: SSWDBStaticCacheDictionarySpec)
		keyedOn: aSymbol;
		yourself
]

{ #category : #'*SSW ReStore Collections' }
Dictionary class >> of: targetClass keyedOn: aSymbol [

	"ReStore specification method - create and return an appropriate SSWDBCollectionSpec"

	^self new of: targetClass keyedOn: aSymbol
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> staticCollectionSpecClass [ 

	"Do not implement this method, the staticCollectionSpecClass for Dictionaries varies
	(see of:xxxx: variants)"

	^self shouldNotImplement


]
