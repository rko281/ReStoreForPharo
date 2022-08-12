Extension { #name : #Collection }

{ #category : #'*SSW ReStore Collections' }
Collection >> _dbAdd: anObject [

	"For use when instantiating a collection from the database.
	Normally the same as add: but see SortedCollection implementation"

	^self add: anObject
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _dbAdd: anObject suggestedIndex: anInteger [

	"Add anObject to the receiver, possibly at the index anInteger.
	The suggestedIndex is only required by keyed collections so defer to just _dbAdd:"

	^self _dbAdd: anObject
]

{ #category : #'*SSW ReStore Collections' }
Collection >> _fetchAll: aCollection [

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
Collection >> _proxifyIn: aCollectionProxy [

	aCollectionProxy _proxiedObject: self.
	^self
]

{ #category : #'*SSW ReStore Collections' }
Collection >> fetch: aSymbol [

	"ReStore - for each element of the receiver, use a single query (ideally, or multiple batched queries if the receiver's size is too large for the readAll batch size)
	to fetch from the database the component in the inst var named aSymbol"

	^self fetchAll: (Array with: aSymbol)
]

{ #category : #'*SSW ReStore Collections' }
Collection >> fetchAll: aCollection [

	"ReStore - for each element of the receiver, use a single query (ideally, or multiple batched queries if the receiver's size is too large for the readAll batch size)
	to fetch from the database the components in the inst vars named in aCollection"

	^(self select: [ :each | each _isRecovered]) _fetchAll: aCollection
]

{ #category : #'*SSW ReStore Collections' }
Collection >> isOrdered [

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
