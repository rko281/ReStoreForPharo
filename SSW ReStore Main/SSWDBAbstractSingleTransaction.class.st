"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBAbstractSingleTransaction',
	#superclass : 'SSWDBTransaction',
	#instVars : [
		'allReferencedObjects',
		'currentReferencedObjects',
		'activeProxiesMap',
		'changedObjects',
		'allocatedIDs',
		'deletedObjects'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> abandon [

	"End this transaction, leaving objects in their current state (unlike rollback which returns them to their state prior to the transaction)"

	self currentReferencedObjects do: [ :each | each _unswap].
	self endObjectCollection
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> activeProxiesMap [

	"activeProxiesMap stores an IdentityDictionary mapping objects active in this transaction to their proxy"

	^activeProxiesMap
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> activeProxiesMap: anIdentityDictionary [

	"activeProxiesMap stores an IdentityDictionary mapping objects active in this transaction to their proxy"

	activeProxiesMap := anIdentityDictionary
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> addDeletedObject: aDBProxy [

	^self deletedObjects add: aDBProxy
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> allReferencedObjects [

	"allReferencedObjects stores a collection of all objects referenced during this transaction. 
	It is created/added to following each phase	(see comment to currentReferencedObjects)"
	
	^allReferencedObjects
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> allReferencedObjects: anIdentitySet [

	"allReferencedObjects stores a collection of all objects referenced during this transaction. 
	It is created/added to following each phase	(see comment to currentReferencedObjects)"
	
	allReferencedObjects := anIdentitySet
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> allocateIDFor: anObject tableRecord: aDBTableRecord [

	| allocated |

	allocated := self allocatedIDs at: aDBTableRecord ifAbsentPut: [OrderedCollection new: 32].

	^allocated add:
		(SSWDBAllocatedID new
			tableRecord: aDBTableRecord;
			offset: allocated size;
			object: anObject;
			yourself)
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> allocatedIDs [

	"allocatedIDs stores SSWDBAllocatedIDs allocated to newly-persistent objects during a commit of the receiver.
	Structure is a Dictionary mapping tables to IDs allocated in each table"

	^allocatedIDs
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> allocatedIDs: anIdentityDictionary [

	"allocatedIDs stores SSWDBAllocatedIDs allocated to newly-persistent objects during a commit of the receiver.
	Structure is a Dictionary mapping tables to IDs allocated in each table"

	allocatedIDs := anIdentityDictionary
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> autoRecoverCommitIn: anSSWReStore [

	"Attempt to fix up the receiver following an error during the commit stage"

	"Any objects referenced during the errored commit will erroneously be in currentReferencedObjects.
	Swap back and forget"
	self currentReferencedObjects do: [ :obj | obj _unswap].

	"The receiver's changedObjects should now be the currentReferencedObjects"
	self currentReferencedObjects: (self changedObjects collect: [ :obj | obj _swap]).
	self allReferencedObjects: self newEmptyObjectsSet
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> autoRecoverPreCommitIn: anSSWReStore [

	"Attempt to fix up the receiver following an error during the pre-commit stage"

	"Move allReferencedObjects back to currentReferencedObjects"
	self currentReferencedObjects addAll: self allReferencedObjects.
	self allReferencedObjects: self newEmptyObjectsSet
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> begin [

	"Initialize the receiver transaction"
	
	self
		allocatedIDs: (IdentityDictionary new: 64);
		activeProxiesMap: (IdentityDictionary new: 128);
		beginObjectCollection
]

{ #category : 'initializing' }
SSWDBAbstractSingleTransaction >> beginObjectCollection [

	"Initialize the receiver transaction to begin accumulating referenced objects"
	
	self 
		currentReferencedObjects: self newEmptyObjectsSet;
		allReferencedObjects: self newEmptyObjectsSet;
		deletedObjects: self newEmptyObjectsSet
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> beginWithin: anotherTransaction [

	"For single (non-nested) transactions, anotherTransaction should always be nil.
	Defer to begin, or error if anotherTransaction is not nil"
	
	anotherTransaction = nil
		ifTrue: [self begin]
		ifFalse: [self error: 'Nesting of transaction not supported']
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> changedObjects [

	"changedObjects stores the collection of objects changed within this transaction.
	It is constructed from referencedObjects during pre-commit"
	
	^changedObjects
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> changedObjects: anIdentitySet [

	"changedObjects stores the collection of objects changed within this transaction.
	It is constructed from referencedObjects during pre-commit"
	
	changedObjects := anIdentitySet
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> commitAllocatedIDs [

	self allocatedIDs keysAndValuesDo: 
		[ :tableRecord :ids |
		[| directTableRecord nextID statement |
		"Avoid invoking change detection system by referencing proxied table record directly"
		directTableRecord := tableRecord _proxiedObject.
		nextID := directTableRecord nextID + ids size.
		statement := tableRecord _reStore nextIDStatement.
		statement values: (Array with: nextID with: tableRecord _id with: directTableRecord nextID); exec.
		statement rowsAffected = 1] whileFalse: 
			["Update clash; refresh and try again"
			tableRecord _recoverProxiedObject]]
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> currentReferencedObjects [

	"currentReferencedObjects stores a collection of all objects that are referenced 
	during the current 'phase' of the receiver. Phases are
	 - initial use (following begin)
	 - each pre-commital loop (see prepareToCommit)"
	
	^currentReferencedObjects
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> currentReferencedObjects: anIdentitySet [

	"currentReferencedObjects stores a collection of all objects that are referenced 
	during the current 'phase' of the receiver. Phases are
	 - initial use (following begin)
	 - each pre-commital loop (see prepareToCommit)"
	
	currentReferencedObjects := anIdentitySet
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> deletedObjects [

	"deletedObjects stores any persistent objects which have been deleted during this transaction.
	This is used to prevent redundant duplicate deletion attempts, e.g. where an object is a member of a deleted collection"
	
	^deletedObjects
]

{ #category : 'accessing' }
SSWDBAbstractSingleTransaction >> deletedObjects: anIdentitySet [

	"deletedObjects stores any persistent objects which have been deleted during this transaction.
	This is used to prevent redundant duplicate deletion attempts, e.g. where an object is a member of a deleted collection"
	
	deletedObjects := anIdentitySet
]

{ #category : 'initializing' }
SSWDBAbstractSingleTransaction >> endObjectCollection [

	"End the accumulation of referenced objects"

	self 
		allReferencedObjects: nil;
		currentReferencedObjects: self newEmptyObjectsSet
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> ensureIsActive: anObject [

	"Ensure anObject is currently active (i.e.is in the currentReferencedObjects set) if it is already present in this transaction.
	Return whether anObject exists in this transaction"

	^(self activeProxiesMap at: anObject ifPresent: [ :proxy | self currentReferencedObjects add: proxy]) notNil
]

{ #category : 'testing' }
SSWDBAbstractSingleTransaction >> includesProxiedObject: anObject [

	^self activeProxiesMap includesKey: anObject
]

{ #category : 'testing' }
SSWDBAbstractSingleTransaction >> includesProxy: anSSWDBProxy [

	^(self currentReferencedObjects includes: anSSWDBProxy)
		or: [self allReferencedObjects includes: anSSWDBProxy]
]

{ #category : 'testing' }
SSWDBAbstractSingleTransaction >> isAlreadyDeleted: aDBProxy [

	^self deletedObjects includes: aDBProxy
]

{ #category : 'evaluating' }
SSWDBAbstractSingleTransaction >> newEmptyObjectsSet [

	"Return an empty Set of a default size that can be used for holding proxies"

	^self newEmptyObjectsSet: 128
]

{ #category : 'evaluating' }
SSWDBAbstractSingleTransaction >> newEmptyObjectsSet: anInteger [

	"Return an empty Set that can be used for holding proxies"

	^IdentitySet new: anInteger
]

{ #category : 'initializing' }
SSWDBAbstractSingleTransaction >> nextCollectionPhase [

	self allReferencedObjects isEmpty
		ifTrue: [self allReferencedObjects: self currentReferencedObjects]
		ifFalse: [self allReferencedObjects addAll: self currentReferencedObjects].

	self currentReferencedObjects: (self newEmptyObjectsSet: self currentReferencedObjects size)

]

{ #category : 'evaluating' }
SSWDBAbstractSingleTransaction >> ownerTransaction [

	"For a single (non-nested transaction) the ownerTransaction is always nil"
	
	^nil
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> postCommitAllocatedIDs [

	self allocatedIDs keysAndValuesDo: 
		[ :tableRecord :ids |

		ids do: [ :id | id postCommit].
		"Avoid invoking change detection system by referencing proxied table record directly"
		tableRecord _proxiedObject incrementNextIDBy: ids size]
]

{ #category : 'actions' }
SSWDBAbstractSingleTransaction >> prepareToCommit [

	| changed unchanged currentObjects |

	changed := self newEmptyObjectsSet: (self currentReferencedObjects size // 2).
	unchanged := self newEmptyObjectsSet: (self currentReferencedObjects size // 2).

	"Pre-write validate the changed objects. This may cause other objects to be added to the transaction,
	so repeat until no more changed objects are found"
	[self currentReferencedObjects isEmpty] whileFalse:
		[| needingPhase2 |
		currentObjects := self currentReferencedObjects.
		needingPhase2 := self newEmptyObjectsSet.
		self nextCollectionPhase.
		currentObjects do: 
			[ :proxy | 
			(changed includes: proxy) ifFalse:
				[proxy _hasChanged 
				ifTrue: 
					[changed add: proxy.
					proxy _prepareToCommitPhase1 ifTrue: [needingPhase2 add: proxy]]
				ifFalse:
					[unchanged add: proxy]]].
		needingPhase2 do: [ :each | each _prepareToCommitPhase2]].
	
	self changedObjects: (changed collect: [ :proxy | proxy _unswap]). 
	unchanged do: [ :each | each isDBProxy ifTrue: [each _unswap]].

	self endObjectCollection
]

{ #category : 'proxy tracking' }
SSWDBAbstractSingleTransaction >> proxy: aDBProxy forwarded: aMessage [

	"Add aDBProxy to the collection of potentially-changed objects (the receiver performs no checking on the message sent)"

	aDBProxy _proxiedObject ifNotNil: [ :object | self activeProxiesMap at: object put: aDBProxy].
	self currentReferencedObjects add: aDBProxy
]

{ #category : 'proxy tracking' }
SSWDBAbstractSingleTransaction >> proxyForObject: anObject ifNone: aBlock [

	^self activeProxiesMap at: anObject ifAbsent: aBlock
]

{ #category : 'proxy tracking' }
SSWDBAbstractSingleTransaction >> removeProxy: aProxydObject [

	"Remove aProxydObject from the collections of potentially-changed objects"

	self currentReferencedObjects remove: aProxydObject ifAbsent: [].
	self allReferencedObjects remove: aProxydObject ifAbsent: []
]

{ #category : 'initializing' }
SSWDBAbstractSingleTransaction >> resetChangedObjects [

	self changedObjects: nil
]
