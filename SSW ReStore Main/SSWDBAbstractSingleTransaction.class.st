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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> abandon [

	"End this transaction, leaving objects in their current state (unlike rollback which returns them to their state prior to the transaction)"

	currentReferencedObjects do: 
		[ :proxy | 
		proxy _isPersistent 
			ifTrue: [proxy _armWriteBarrier]
			ifFalse: [activeProxiesMap removeKey: proxy _proxiedObject]].
	
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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> addProxy: aDBProxy [

	"Add aDBProxy to the collection of potentially-changed objects.
	ASSERT: aDBProxy is swapped, wearing the back-face identity of the pair."

	self activeProxiesMap at: aDBProxy _proxiedObject put: aDBProxy.

	aDBProxy _isDirty 
		ifTrue: [self currentReferencedObjects add: aDBProxy]
		ifFalse: [aDBProxy _armWriteBarrier]
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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> autoRecoverCommitIn: anSSWReStore [

	"Attempt to fix up the receiver following an error during the commit stage"

	"The receiver's changedObjects should now be the currentReferencedObjects"
	self currentReferencedObjects: self changedObjects.
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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> beginWithin: anotherTransaction [

	"For single (non-nested) transactions, anotherTransaction should always be nil.
	Defer to begin, or error if anotherTransaction is not nil"
	
	anotherTransaction isNil ifTrue: [^self begin].

	anotherTransaction isDumb 
		ifTrue: [anotherTransaction abandon]
		ifFalse: [self error: 'Nesting of transaction not supported'].

	self
		allocatedIDs: (IdentityDictionary new: 64);
		beginObjectCollection;
		activeProxiesMap: anotherTransaction activeProxiesMap
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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> endObjectCollection [

	"End the accumulation of referenced objects"

	self 
		allReferencedObjects: self newEmptyObjectsSet;
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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> isAlreadyDeleted: aDBProxy [

	^(self deletedObjects includes: aDBProxy) or: [self deletedObjects includes: aDBProxy _proxiedObject]
]

{ #category : 'testing' }
SSWDBAbstractSingleTransaction >> isEmpty [

	^self activeProxiesMap isEmpty
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

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> ownerTransaction [

	^SSWDBDumbTransaction new
		beginObjectCollection;
		activeProxiesMap: self activeProxiesMap;
		yourself
]

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> postCommitAllocatedIDs [

	self allocatedIDs keysAndValuesDo: 
		[ :tableRecord :ids |
		ids do: 
			[ :id | 
			self activeProxiesMap at: id object ifPresent: [ :proxy | id object: proxy].
			id postCommit].
		"Avoid invoking change detection system by referencing proxied table record directly"
		tableRecord _proxiedObject incrementNextIDBy: ids size].

	self allocatedIDs: IdentityDictionary new
]

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> prepareToCommit [

	| changed currentObjects |

	changed := self newEmptyObjectsSet: self currentReferencedObjects size // 2.

	"Pre-write validate the changed objects. This may cause other objects to be added to the transaction,
	so repeat until no more changed objects are found"
	[ self currentReferencedObjects isEmpty ] whileFalse: [
		| needingPhase2 |
		currentObjects := self currentReferencedObjects.
		needingPhase2 := self newEmptyObjectsSet.
		self nextCollectionPhase.
		currentObjects do: [ :proxy |
			(changed includes: proxy) ifFalse: [
				proxy _hasChanged ifTrue: [
					changed add: proxy.
					proxy _prepareToCommitPhase1 ifTrue: [ needingPhase2 add: proxy ] ] ] ].
		needingPhase2 do: [ :each | each _prepareToCommitPhase2 ] ].

	self changedObjects: changed.
	self endObjectCollection
]

{ #category : 'proxy tracking' }
SSWDBAbstractSingleTransaction >> proxyForObject: anObject ifNone: aBlock [

	^self activeProxiesMap at: anObject ifAbsent: aBlock
]

{ #category : 'operations' }
SSWDBAbstractSingleTransaction >> removeProxy: aDBProxy [

	"Remove aDBProxy from the collections of potentially-changed objects"

	aDBProxy _isSwapped
	ifTrue: 
		["The standard though unusual case of an object being stored and unstored in one transaction. In this case we also need to remove any allocated ID"
		aDBProxy _isNew ifTrue: [self allocatedIDs at: aDBProxy _tableRecord ifPresent: [ :allocIDs | allocIDs removeAllSuchThat: [ :each | each object == aDBProxy _proxiedObject]]].
		self currentReferencedObjects remove: aDBProxy ifAbsent: [].
		self allReferencedObjects ifNotNil: [ :all | all remove: aDBProxy ifAbsent: []]. "May be empty"
		self activeProxiesMap removeKey: aDBProxy _proxiedObject ifAbsent: []]
	ifFalse: 
		["aDBProxy has been unswapped after earlier being swapped into this transaction, hence the receiver now contains the proxied object in place of the proxy and vice versa"
		self currentReferencedObjects remove: aDBProxy _proxiedObject ifAbsent: [].
		self allReferencedObjects ifNotNil: [ :all | all remove: aDBProxy _proxiedObject ifAbsent: []]. "May be empty"
		self activeProxiesMap removeKey: aDBProxy ifAbsent: []]
]

{ #category : 'initializing' }
SSWDBAbstractSingleTransaction >> resetChangedObjects [

	self changedObjects: nil
]
