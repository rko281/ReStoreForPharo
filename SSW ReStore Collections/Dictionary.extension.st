Extension { #name : 'Dictionary' }

{ #category : '*SSW ReStore Collections' }
Dictionary >> _dbAdd: targetObject suggestedIndex: keyObject [

	"Make the receiver polymorphic with an indexed collection. keyObject = index"

	^self at: keyObject put: targetObject
]

{ #category : '*SSW ReStore Collections' }
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

{ #category : '*SSW ReStore Collections' }
Dictionary >> of: targetClass keyClass: keyClass [

	"Private - ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The Dictionary's keys will be of the class keyClass, which should be a valid persistent class.
	Create and return an appropriate SSWDBCollectionSpec"

	^(self of: targetClass specClass: self staticDictionarySpecClass)
		setKeyClass: keyClass;
		yourself
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> of: targetClass keyedOn: aSymbolOrBlock [

	"Private - ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The target class may alternatively be a collection specification (e.g. OrderedCollection of: Person) for a multi-value dictionary.
	Instances are stored in the receiver at: the value detemined by evaluating aSymbolOrBlock with them (usually but not always the value of an instance variable).
	Create and return an appropriate SSWDBCollectionSpec"

	| spec |

	(targetClass isKindOf: SSWDBCollectionSpec)
	ifTrue: 
		[spec := self of: targetClass targetClass specClass: self staticMultiValueCacheDictionarySpecClass.
		targetClass isValueDependent ifTrue: [spec beValueDependent]]
	ifFalse: 
		[spec := self of: targetClass specClass: self staticCacheDictionarySpecClass].

	^spec
		keyedOn: aSymbolOrBlock;
		yourself
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> of: anAssociation owner: aSymbol [

	"Private - ReStore specification method - specify a Dictionary which stores instances of the class which is the value of anAssociation.
	The key of Association should be an instance variable name (Symbol) of the value class; the contents of this instance variable is used as the key for each element, e.g. Dictionary of: #surname -> Person
	Create and return an appropriate SSWDBCollectionSpec"

	^self of: anAssociation value owner: aSymbol keyedOn: anAssociation key
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> of: targetClass owner: ownerSymbol keyedOn: aSymbol [

	"Private - ReStore specification method - specify a Dictionary which stores instances of targetClass.
	The target class may alternatively be a collection specification (e.g. OrderedCollection of: Person) for a multi-value dictionary.
	Instances are stored in the receiver at: the value detemined by evaluating aSymbolOrBlock with them (usually but not always the value of an instance variable).
	Create and return an appropriate SSWDBCollectionSpec"

	| spec |

	(targetClass isKindOf: SSWDBCollectionSpec)
	ifTrue: 
		[spec := self of: targetClass targetClass specClass: self ownedMultiValueCacheDictionarySpecClass.
		targetClass isValueDependent ifTrue: [spec beValueDependent]]
	ifFalse: 
		[spec := self of: targetClass specClass: self ownedCacheDictionarySpecClass].

	^spec
		owner: ownerSymbol;
		keyedOn: aSymbol;
		yourself
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> ownedCacheDictionarySpecClass [

	^SSWDBOwnedCacheDictionarySpec
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> ownedMultiValueCacheDictionarySpecClass [

	^SSWDBOwnedMultiValueCacheDictionarySpec
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> staticCacheDictionarySpecClass [

	^SSWDBStaticCacheDictionarySpec
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> staticCollectionSpecClass [ 

	"Do not implement this method, the staticCollectionSpecClass for Dictionaries varies
	(see of:xxxx: variants)"

	^self shouldNotImplement


]

{ #category : '*SSW ReStore Collections' }
Dictionary >> staticDictionarySpecClass [

	^SSWDBStaticDictionarySpec
]

{ #category : '*SSW ReStore Collections' }
Dictionary >> staticMultiValueCacheDictionarySpecClass [

	^SSWDBStaticMultiValueCacheDictionarySpec
]
