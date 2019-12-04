Extension { #name : #Collection }

{ #category : #'*SSW ReStore Collections' }
Collection >> _changesFrom: aCollectionOfEntries [

	"Return the changes made to the receiver compared to aCollectionOf(SSWDBCollection)Entries,
	as a collection of SSWDBCollectionChanges"

	^self subclassResponsibility
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _collectionAdditions [

	"Return an collection of SSWDBCollectionAdditions representing the addition of 
	all the receiver's elements to an empty collection.
	Default - defer to _nonKeyedCollectionAdditions (assume receiver does not support keys). 
	Collections with keys/indexes should reimplement to include key/index information"

	^self _nonKeyedCollectionAdditions
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _dbAdd: anObject [

	"For use when instantiating a collection from the database.
	Normally the same as add: but see SortedCollection implementation"

	^self add: anObject
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _fetchComponents: aCollection [

	"Private - ReStore - for each element of the receiver, use a single query (ideally, or multiple batched queries if the receiver's size is too large for the readAll batch size)
	to fetch from the database the components in the inst vars named in aCollection"

	| any reStore table |

	self isEmpty ifTrue: [^self].
	any := self anyOne. 
	reStore := any _reStore.
	table := reStore tableForClass: any class.

	aCollection do: [ :instVar | (table componentAccessing: instVar) readAllFor: self]

	
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _keyRemovalsIn: aCollectionOfChanges [

	"Return a collection of SSWDBCollectionObjectRemovals representing those keys (indexes)
	removed from the receiver by aCollectionOfChanges.

	Default - none. Subclasses for whom this is important (i.e. have persistent indexes) should implement"

	^#()
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _keyedChangesFrom: aCollectionOfEntries [

	"Return the changes made to the receiver compared to aCollectionOf(Collection)Entries.
	For keyed changes, must consider additions, removals and changes of key"

	| changes map |

	changes := OrderedCollection new: (self size // 10).
	map := IdentityDictionary new: aCollectionOfEntries size.

	"Make a map of each element (as was) to its entry(s)"
	aCollectionOfEntries do: 
		[ :each | (map at: each target ifAbsentPut: [OrderedCollection new: 1]) addLast: each].

	"Locate and remove entry for each member of the receiver and check for key change"
	self keysAndValuesDo:
		[ :newKey :each || entry |
		entry := (map at: each ifAbsent: [(OrderedCollection new)]) removeFirstIfAbsent:
			"No entry found = element has been added to the receiver" 
			[(changes add: (SSWDBCollectionAddition added: each at: newKey)) affectedEntry].
		entry index = newKey ifFalse: 
			[changes add: (SSWDBCollectionIndexUpdate entry: entry newIndex: newKey)]].

	"Any remaining entries indicate elements removed from the receiver"
	map keysAndValuesDo:
		[ :each :entries | 
		entries isEmpty ifFalse:		"Minor optimisation"
			[entries do: [ :entry | changes add: (SSWDBCollectionRemoval newWithEntry: entry)]]].

	^changes
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _keyedCollectionAdditions [

	"Return a collection of SSWDBCollectionAdditions representing the addition of 
	all the receiver's elements to an empty collection. 
	Include the key of each element (as used by keysAndValuesDo:)"

	| additions |

	additions := OrderedCollection new.

	self keysAndValuesDo: [ :key :each | additions add: (SSWDBCollectionAddition added: each at: key)].

	^additions
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _nonKeyedCollectionAdditions [

	"Return an collection of SSWDBCollectionAdditions representing the addition of 
	all the receiver's elements to an empty collection.
	The SSWDBCollectionAdditions do not contain key information"

	| additions |

	additions := OrderedCollection new.

	self do: [ :each | additions add: (SSWDBCollectionAddition added: each)].

	^additions
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _valueRemovalsIn: aCollectionOfChanges [

	"Return a collection of SSWDBCollectionObjectRemovals representing those values (objects)
	removed from the receiver which are the targets of the affectedEntries of aCollectionOfChanges"

	| removalChanges |

	"Restrict the changes to just those that can potentially result in the removal of a value object"
	removalChanges := aCollectionOfChanges select: [ :change | change canRemoveValue].

	^(self _valuesRemovedBy: removalChanges) collect: 
		[ :valueObject | SSWDBCollectionObjectRemoval newWithObject: valueObject]
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _valuesRemovedBy: aCollectionOfChanges [

	"Return those values (objects) completely removed from the receiver by aCollectionOfChanges"

	| affectedObjects |

	affectedObjects := aCollectionOfChanges collect: [ :change | change affectedEntry target].

	^affectedObjects asIdentitySet reject: [ :object | self identityIncludes: object]
]

{ #category : #'*SSW ReStore Collections' }
Collection >> directAdd: anObject [

	"Add anObject to the receiver.
	Sent by ReStore when populating a collection; assume elements are added in correct order
	and so bypass any internal ordering (e.g. see SortedCollection>>directAdd:)"

	^self add: anObject
]

{ #category : #'*SSW ReStore Collections' }
Collection >> directAdd: anObject suggestedIndex: anInteger [

	"Add anObject to the receiver, possibly at the index anInteger.
	The suggestedIndex is only required by keyed collections, 
	so defer to just directAdd:"

	^self directAdd: anObject
]

{ #category : #'*SSW ReStore Collections' }
Collection >> fetchComponent: aSymbol [

	"ReStore - for each element of the receiver, use a single query (ideally, or multiple batched queries if the receiver's size is too large for the readAll batch size)
	to fetch from the database the component in the inst var named aSymbol"

	^self fetchComponents: (Array with: aSymbol)
]

{ #category : #'*SSW ReStore Collections' }
Collection >> fetchComponents: aCollection [

	"ReStore - for each element of the receiver, use a single query (ideally, or multiple batched queries if the receiver's size is too large for the readAll batch size)
	to fetch from the database the components in the inst vars named in aCollection"

	^(self select: [ :each | each _isRecovered]) _fetchComponents: aCollection
]

{ #category : #'*SSW ReStore Collections' }
Collection >> isOrdered [

	^false

]

{ #category : #'*SSW ReStore Collections' }
Collection >> isSortedCollection [

	^false

]

{ #category : #'*SSW ReStore Collections' }
Collection >> isValidForPersistence [

	"Collections are not persisted directly (e.g. via storeIn:), therefore consider them already persistent"

	^true
]

{ #category : #'*SSW ReStore Collections' }
Collection class >> of: targetClass [

	^self new of: targetClass

]

{ #category : #'*SSW ReStore Collections' }
Collection >> of: targetClass [

	"ReStore specification method - specifies a general (M to M) collection containing aClass.
	Create and return an appropriate SSWDBCollectionSpec"

	^self of: targetClass specClass: self staticCollectionSpecClass
]

{ #category : #'*SSW ReStore Collections' }
Collection class >> of: targetClass owner: aSymbol [

	^self new of: targetClass owner: aSymbol


]

{ #category : #'*SSW ReStore Collections' }
Collection >> of: targetClass owner: aSymbol [

	"ReStore specification method - specifies a 1 to many collection, containing aClass,
	whose inst var named aSymbol holds the owning (1) object.

	Create and return an appropriate SSWDBCollectionSpec"

	^self ownedCollectionSpecClass new
		templateCollection: self;
		setTargetClass: targetClass;
		owner: aSymbol;
		yourself

]

{ #category : #'*SSW ReStore Collections' }
Collection >> of: targetClass specClass: specClass [

	"ReStore specification method - specifies a general (M to M) collection containing aClass.
	Create, initialize and return a configured instance of the given SSWDBCollectionSpec class"

	^specClass new
		templateCollection: self;
		setTargetClass: targetClass;
		yourself
]

{ #category : #'*SSW ReStore Collections' }
Collection >> orRemote [

	"The receiver is already in memory, return it"

	^self
]

{ #category : #'*SSW ReStore Collections' }
Collection >> ownedCollectionSpecClass [ 

	"Return the class of owned collection spec that is appropriate for this kind of collection"

	^SSWDBOwnedCollectionSpec


]

{ #category : #'*SSW ReStore Collections' }
Collection >> remote [

	"Defer to the proxy"

	^self _dbProxy remote
]

{ #category : #'*SSW ReStore Collections' }
Collection >> staticCollectionSpecClass [ 

	"Return the class of static collection spec that is appropriate for this kind of collection.
	Subclasses for which this may differ depending on mode of use should not implement this,
	but should route configuration through of:specClass: "

	^SSWDBStaticCollectionSpec


]
