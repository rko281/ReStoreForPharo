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
		[(aCollectionOfEntries first isKindOf: SSWDBCacheDictionaryEntry)
		ifTrue: 
			[self _isMultiValue
				ifTrue: [self _multiValueChangesFrom: aCollectionOfEntries]
				ifFalse: [super _changesFrom: aCollectionOfEntries]]
		ifFalse: 
			[self _keyedChangesFrom: aCollectionOfEntries]]
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _collectionAdditions [

	"Override to 
	 - check for multi-value dictionary
	 - include key information"

	^self _isMultiValue
		ifTrue: [self _multiValueKeyedCollectionAdditions]
		ifFalse: [self _keyedCollectionAdditions]
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _dbAdd: targetObject suggestedIndex: keyObject [

	"Make the receiver polymorphic with an indexed collection. keyObject = index"

	^self at: keyObject put: targetObject
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _dbKeyUpdateClass [

	^SSWDBCollectionKeyUpdate
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _dbRemovalClass [

	^SSWDBCollectionRemovalWithKey
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _isMultiValue [

	^self isEmpty not and: [(self anyOne isKindOf: Collection) and: [self anyOne isString not]]
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _multiValueChangesFrom: aCollectionOfEntries [

	"Return the changes made to the receiver compared to aCollectionOf(Dictionary)Entries.
	The receiver is a multi-value dictionary"

	| allValues changes |

	allValues := self inject: (IdentitySet new: self size * 4) into: [ :all :values | all addAll: values; yourself].
	changes := OrderedCollection new.

	aCollectionOfEntries do: 
		[ :entry |
		((self at: entry key ifAbsent: [#()]) includes: entry target) 
			ifTrue: [allValues remove: entry target]
			ifFalse: [changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	allValues do: [ :each | changes add: (SSWDBCollectionAddition added: each)].

	^changes
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _multiValueKeyedCollectionAdditions [

	| additions |

	additions := OrderedCollection new.

	self keysAndValuesDo: [ :key :values | values do: [ :each | additions add: (SSWDBCollectionAddition added: each at: key)]].

	^additions
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> _valuesRemovedBy: aCollectionOfChanges [

	"The receiver is not a set (i.e. allows duplicates) and so cannot take advantage of superclass optimisation"

	^self _superValuesRemovedBy: aCollectionOfChanges
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: anAssociation [

	"ReStore specification method - specify a Dictionary which stores instances of the class which is the value of anAssociation.
	The key of Association should be either:
	 - the class of the keys of the Dictionary, e.g.  Dictionary of: DateAndTime -> CustomerOrder
	OR
	 - an instance variable name (Symbol) of the value class; the contents of this instance variable is used as the key for each element, e.g. Dictionary of: #surname -> Person
	OR
	 - a 1-arg Block which is evaluated with each elements to derive the key, e.g. Dictionary of: [ :obj | obj name asLowercase] -> Person
	Create and return an appropriate SSWDBCollectionSpec"

	^(anAssociation key isSymbol or: [anAssociation key isKindOf: BlockClosure])
		ifTrue: [self of: anAssociation value keyedOn: anAssociation key]
		ifFalse: [self of: anAssociation value keyClass: anAssociation key]

]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: targetClass keyClass: keyClass [

	"Private - ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The Dictionary's keys will be of the class keyClass, which should be a valid persistent class.
	Create and return an appropriate SSWDBCollectionSpec"

	^(self of: targetClass specClass: SSWDBStaticDictionarySpec)
		setKeyClass: keyClass;
		yourself
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: targetClass keyedOn: aSymbolOrBlock [

	"Private - ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The target class may alternatively be a collection specification (e.g. OrderedCollection of: Person) for a multi-value dictionary.
	Instances are stored in the receiver at: the value detemined by evaluating aSymbolOrBlock with them (usually but not always the value of an instance variable).
	Create and return an appropriate SSWDBCollectionSpec"

	| spec |

	(targetClass isKindOf: SSWDBCollectionSpec)
	ifTrue: 
		[spec := self of: targetClass targetClass specClass: SSWDBStaticMultiValueCacheDictionarySpec.
		targetClass isValueDependent ifTrue: [spec beValueDependent]]
	ifFalse: 
		[spec := self of: targetClass specClass: SSWDBStaticCacheDictionarySpec].

	^spec
		keyedOn: aSymbolOrBlock;
		yourself
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: anAssociation owner: aSymbol [

	"Private - ReStore specification method - specify a Dictionary which stores instances of the class which is the value of anAssociation.
	The key of Association should be an instance variable name (Symbol) of the value class; the contents of this instance variable is used as the key for each element, e.g. Dictionary of: #surname -> Person
	Create and return an appropriate SSWDBCollectionSpec"

	^self of: anAssociation value owner: aSymbol keyedOn: anAssociation key
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> of: targetClass owner: ownerSymbol keyedOn: aSymbol [

	"Private - ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The target class may alternatively be a collection specification (e.g. OrderedCollection of: Person) for a multi-value dictionary.
	Instances are stored in the receiver at: the value detemined by evaluating aSymbolOrBlock with them (usually but not always the value of an instance variable).
	Create and return an appropriate SSWDBCollectionSpec"

	| spec |

	(targetClass isKindOf: SSWDBCollectionSpec)
	ifTrue: 
		[spec := self of: targetClass targetClass specClass: SSWDBOwnedMultiValueCacheDictionarySpec.
		targetClass isValueDependent ifTrue: [spec beValueDependent]]
	ifFalse: 
		[spec := self of: targetClass specClass: SSWDBOwnedCacheDictionarySpec].

	^spec
		owner: ownerSymbol;
		keyedOn: aSymbol;
		yourself
]

{ #category : #'*SSW ReStore Collections' }
Dictionary >> staticCollectionSpecClass [ 

	"Do not implement this method, the staticCollectionSpecClass for Dictionaries varies
	(see of:xxxx: variants)"

	^self shouldNotImplement


]
