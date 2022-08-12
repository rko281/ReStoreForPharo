"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBObjectProxy,
	#superclass : #SSWDBProxy,
	#instVars : [
		'class',
		'id',
		'collectionProxies'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'instance creation' }
SSWDBObjectProxy class >> _forNewObject: anObject withID: anInteger inReStore: aReStore [

	^(self _forObjectOfClass: anObject class withID: anInteger  inReStore: aReStore)
		_setNewNonPersistent;
		_newProxiedObject: anObject;
		_collectionProxies: IdentityDictionary new;
		yourself
]

{ #category : #'instance creation' }
SSWDBObjectProxy class >> _forObjectOfClass: aClass withID: anObject inReStore: aReStore [

	^self new
		_reStore: aReStore;
		_class: aClass;
		_id: (aClass reStoreIDClass instanceFromDBValue: anObject in: aReStore);
		yourself
]

{ #category : #constants }
SSWDBObjectProxy class >> controlFields [

	"Return any fields required by instances of the receiver 
	to control their operation.

	None by default, subclasses should override as necessary"

	^SSWSQLFieldCollection new
]

{ #category : #testing }
SSWDBObjectProxy class >> isAbstract [

	^self == SSWDBObjectProxy or: [super isAbstract]
]

{ #category : #constants }
SSWDBObjectProxy class >> modifyUpdatesFor: anSSWDBTable [

	"Return any updates that should be applied to rows in anSSWDBTable when carrying out a modify: update.

	None by default, subclasses should override as necessary"

	^OrderedCollection new
]

{ #category : #forwarding }
SSWDBObjectProxy >> = anotherObject [

	"No need to fetch the object if #= == #=="

	^self _dbProxyReStore 
	ifNil: 
		[self = anotherObject]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[(self _proxiedClassIsDefinitive and: [(class lookupMethod: #=) == (Object>>#=)])
					ifTrue: [self == anotherObject]
					ifFalse: [self doesNotUnderstand: (Message selector: #= argument: anotherObject) "equality may be the same as identity so we *must* swap, hence DNU rather than forwarding directly"]]
			ifFalse: 
				[self = anotherObject]]]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _acquireCollectionProxiesUsing: collectionSpecs [

	"Cache the proxiedObject's collection proxies, and set the backwards owner reference.
	The CollectionSpecs identifying the collections (equivalent to self _dbTable collectionSpecs) 
	are passed in as an optimisation"

	"If refreshing an existing object, we may already have the collections"
	collectionProxies isNil 
	ifTrue:
		[collectionProxies := IdentityDictionary new: collectionSpecs size.
		collectionSpecs do:
			[ :spec |
			(collectionProxies at: spec put: (spec accessor valueIn: proxiedObject))
				_owner: self]]
	ifFalse:
		[collectionSpecs do: [ :spec | self _updateCollectionProxyUsing: spec]]
]

{ #category : #accessing }
SSWDBObjectProxy >> _class [

	"class stores the Class of the object for which the receiver is a proxy"
	
	^class
]

{ #category : #accessing }
SSWDBObjectProxy >> _class: aClass [

	"class stores the Class of the object for which the receiver is a proxy"
	
	class := aClass
]

{ #category : #accessing }
SSWDBObjectProxy >> _collectionProxies [

	"collectionProxies stores an IdentityDictionary mapping each of 
	the receiver's table's collectionSpecs to the proxied collection in that spec.
	These are maintained by the receiver so actual collections in the proxiedObject
	can be related to their originating proxy"

	^collectionProxies
]

{ #category : #accessing }
SSWDBObjectProxy >> _collectionProxies: anIdentityDictionary [

	"collectionProxies stores an IdentityDictionary mapping each of 
	the receiver's table's collectionSpecs to the proxied collection in that spec.
	These are maintained by the receiver so actual collections in the proxiedObject
	can be related to their originating proxy"

	collectionProxies := anIdentityDictionary
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> _collectionProxyFor: aCollectionSpec [

	"Look up the collection proxy specified by the given spec.
	If none, create and cache it"

	^collectionProxies at: aCollectionSpec ifAbsentPut:
		[aCollectionSpec newProxydCollectionFor: self]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _collectionProxySwapped: aCollectionProxy [

	"The given collection proxy has swapped its references.
	Update the cache"

	^collectionProxies at: aCollectionProxy _collectionSpec put: aCollectionProxy
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _commitChanges [

	"Return a Boolean indicating whether the commit succeeds"

	^self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [self _commitUnstore]
			ifFalse: [self _commitUpdates]]
	ifFalse:
		[self _commitStore]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _commitStore [

	"Private - Return a Boolean indicating whether the commit succeeds"

	reStore insertProxy: self.

	"Assumed to always succeed"
	^true
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _commitUnstore [

	"Private - Return a Boolean indicating whether the commit succeeds"

	reStore deleteProxy: self. 

	"Assumed to always succeed"
	^true

]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _commitUpdates [

	"Private - Return a Boolean indicating whether the commit succeeds"

	| updates |

	updates := self _fieldUpdates.
	
	^updates isEmpty 
		ifTrue: [true]
		ifFalse: [reStore applyUpdates: updates toObject: self]
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> _currentVersion [

	"Re-read the receiver's proxiedObject from the database,
	returning it as a new proxied object.
	NB Intended for privileged clients only; other clients should use currentVersion (no _ prefix)"
	
	| newProxy |
	
	newProxy := self _proxyClass new.
	newProxy _id: id; _class: class; _reStore: reStore.	

	reStore recoverObjectOfClass: class withID: id into: newProxy.
	
	^newProxy
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> _dbTable [

	^reStore tableForClass: class
]

{ #category : #'non forwarding' }
SSWDBObjectProxy >> _debugPrintString [

	^self _isDeleted 
		ifTrue: [self deletedDebugPrintString]
		ifFalse: [super _debugPrintString]
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> _fieldUpdates [

	"Return a collection of SSWSQLFieldAssignments representing changes made to the receiver"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBObjectProxy >> _id [

	"id stores the unique ID (Integer) of the object for which the receiver is a proxy"
	
	^id
]

{ #category : #accessing }
SSWDBObjectProxy >> _id: anInteger [

	"dbID stores the unique ID (Integer) of the object for which the receiver is a proxy"
	
	id := anInteger
]

{ #category : #forwarding }
SSWDBObjectProxy >> _idIn: aReStore [

	"Polymorphic with Object"
	
	^reStore == aReStore 
		ifTrue: [id]
		ifFalse: [nil error: 'incorrect ReStore parameter']
]

{ #category : #forwarding }
SSWDBObjectProxy >> _instVarAt: anInteger [

	"Sent from internal code to access the proxiedObject directly.
	ASSERT: the receiver is a recovered proxy"
	
	^proxiedObject instVarAt: anInteger
]

{ #category : #forwarding }
SSWDBObjectProxy >> _instVarAt: anInteger put: anObject [

	"Sent from internal code to access the proxiedObject directly.
	ASSERT: the receiver is a recovered proxy"
	
	^proxiedObject instVarAt: anInteger put: anObject
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _intern [

	"Register the receiver in its reStore"
	
	reStore registerProxy: self
]

{ #category : #testing }
SSWDBObjectProxy >> _isNew [

	"Return a Boolean indicating whether the receiver does not yet exist in the database"
	
	^self _isPersistent not
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _postCommitChanges [

	"The receiver's changes have successfully been committed.
	Complete follow-on work"

	^self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [self _postCommitUnstore]
			ifFalse: [self _postCommitUpdates]]
	ifFalse:
		[self _postCommitStore]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _postCommitStore [

	"Private - The receiver has been inserted into the database.
	Complete follow-on work"

	self _dbTable idDataField ifNotNil: [ :idDataField | idDataField accessor value: id in: proxiedObject].
	self 
		_setPersistent;
		_intern	"Re-register"
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _postCommitUnstore [

	"Private - The receiver has been successfully deleted from the database.
	Complete follow-on work and notify interest parties"

	| me object |

	reStore uncacheObject: self. 

	me := proxiedObject.
	object := self.

	self _swap.

	object onUnstored.
	me _proxiedObjectMissing
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _postCommitUpdates [

	"Private - The receiver has been successfully updated in the database.
	Complete follow-on work and notify interest parties"
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _postRecovered [

	"Inform the proxiedObject recovery is done"

	proxiedObject onRecovered
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _postSwapReferences [

	"Inform the collectionProxies"

	collectionProxies do: [ :proxy | proxy _owner: self]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _prepareToCommit [

	self _isDeleted ifFalse: [self _storeNonPersistentComponents]
]

{ #category : #testing }
SSWDBObjectProxy >> _proxiedClassIsDefinitive [

	^proxiedObject notNil or: [self _dbTable class == SSWDBTable]
]

{ #category : #accessing }
SSWDBObjectProxy >> _proxiedObjectClass [
	
	^class
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _proxiedObjectMissing [

	"The receiver's proxiedObject (as specified by class/id) is missing.
	Initialize the receiver to represent this"

	self 
		_proxiedObject: (SSWDBDeletedObject newForClass: class id: id);
		_collectionProxies: IdentityDictionary new
]

{ #category : #accessing }
SSWDBObjectProxy >> _proxyString [

	^'%<<1?an un:a >recovered <2p> id=<3p>%>' expandMacrosWith: proxiedObject isNil with: class with: id
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _recoverProxiedObject [

	"Recover the receiver's proxiedObject from the database"
	
	reStore recoverObjectOfClass: class withID: id into: self
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _refreshFromRow: aDatabaseRow table: aDBTable [

	"Return whether the proxiedObject was refreshed at all.
	table is passed in as an optimisation"
	
	^(aDBTable refreshProxy: self whereChangedFromRow: aDatabaseRow)
		ifTrue: [proxiedObject onRefresh. true]
		ifFalse: [false]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _rollbackChanges [

	self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [self _rollbackUnstore]
			ifFalse: [self _rollbackUpdates]]
	ifFalse:
		[self _rollbackStore]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _rollbackStore [

	"Private - The receiver was a newly-persisted object - deregister from the reStore"

	reStore deregisterProxy: self.
	self _unswap
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _rollbackUnstore [

	self 
		_clearDeleted;
		_rollbackUpdates
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _rollbackUpdates [

	"Rollback any changes made to the receiver"

	self subclassResponsibility
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _storeNonPersistentComponents [

	"Ensure that each non-persistent component of the proxiedObject exists in the receiver's reStore"

	| table |

	table := self _dbTable.

	table dataFields do: [ :field | (field accessor valueIn: proxiedObject) _ensurePersistentIn: reStore].
		
	table collectionSpecs do:
		[ :collectionSpec |
		(collectionSpec accessor valueIn: proxiedObject) 
		ifNil: 
			[(self _collectionProxyFor: collectionSpec)
				_setProxiedObject: collectionSpec newCollection;
				_referenced]
		ifNotNil: 
			[ :collection || proxy |
			collection isDBProxy ifFalse: 
				[proxy := self _collectionProxyFor: collectionSpec.
				proxy _proxiedObject == collection ifFalse: 
					["Verify the collection isn't being assigned to >1 persistent object"
					(reStore transaction proxyForObject: collection ifNone: [nil]) isNil ifFalse: [self error: 'attempt to assign collection to >1 persistent object'].
					proxy 
						_setProxiedObject: collection; 
						_referenced]]]]
]

{ #category : #accessing }
SSWDBObjectProxy >> _unrecoveredProxyString [

	^'%<an unrecovered <1p> id=<2p>%>' expandMacrosWith: class with: id
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _unstore [

	"Unstore the receiver's proxyObject - set the receiver's state so that the receiver is recognised as unstored and hence will be deleted at the next commit"

	self _isDeleted ifTrue: [^self].
	self _setDeleted.

	"Notify interested parties"
	self _dbTable aboutToBeUnstored: self.
	proxiedObject onAboutToUnstore.

	self _isPersistent 
		ifTrue: [self __referenced]
		ifFalse: [reStore deregisterProxy: self; removeFromTransaction: self].

	"Separate loops to cope with potential reference swap"
	collectionProxies do: [ :each | each __ensureActive].
	collectionProxies do: [ :each | each _unstore]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _updateCollectionProxyUsing: aCollectionSpec [

	"Return the collection proxy"

	^aCollectionSpec accessor value: (collectionProxies at: aCollectionSpec) in: proxiedObject
]

{ #category : #accessing }
SSWDBObjectProxy >> _valuesForAccessor: anInstVarAccessor [

	"Private - Return the value(s) in the receiver's proxy object(s) which could be accessed by anInstVarAccessor"

	^proxiedObject 
		ifNil: [#()]
		ifNotNil: [{anInstVarAccessor valueIn: proxiedObject}]
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> currentVersion [

	"Re-read the receiver's proxiedObject from the database,
	returning it as a new unproxied object.
	c.f. _currentVersion which returns a proxied object"
	
	^self _currentVersion _proxiedObject
]

{ #category : #'non forwarding' }
SSWDBObjectProxy >> deletedDebugPrintString [

	"Private - The receiver is a deleted proxy; answer an appropriate debugPrintString"

	^'%<a marked-for-deletion <1p>%>' << class
]

{ #category : #forwarding }
SSWDBObjectProxy >> hash [

	"No need to fetch the object if hash == identityHash"

	^self _dbProxyReStore 
	ifNil: 
		[self hash]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[(self _proxiedClassIsDefinitive and: [(class lookupMethod: #hash) == (Object>>#hash)])
					ifTrue: [self identityHash]
					ifFalse: [self doesNotUnderstand: (Message selector: #hash) "hash may be the same as identityHash so we *must* swap, hence DNU rather than forwarding directly"]]
			ifFalse: 
				[self hash]]]
]

{ #category : #'non forwarding' }
SSWDBObjectProxy >> isSQLNull [

	"No need to bother the proxiedObject"
	
	^false
]

{ #category : #forwarding }
SSWDBObjectProxy >> isValidForPersistence [

	^true
]

{ #category : #forwarding }
SSWDBObjectProxy >> printOn: aStream [

	"Do not error on printString to a deleted object"

	^self _dbProxyReStore 
	ifNil: 
		[self printOn: aStream]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[self _isDeleted 
				ifTrue: 
					[aStream nextPutAll: self deletedDebugPrintString]
				ifFalse: 
					[(proxiedObject isNil and: [self _proxiedClassIsDefinitive and: [(class lookupMethod: #printOn:) == (Object>>#printOn:)]])
						ifTrue: [class basicNew printOn: aStream]
						ifFalse: [self _recoveredProxiedObject printOn: aStream]]]
			ifFalse: 
				[self printOn: aStream]]]
]

{ #category : #forwarding }
SSWDBObjectProxy >> printString [

	"Do not error on printString to a deleted object"

	^self _dbProxyReStore 
	ifNil: 
		[self printString]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[self _isDeleted 
				ifTrue: 
					[self deletedDebugPrintString]
				ifFalse: 
					[(proxiedObject isNil and: [self _proxiedClassIsDefinitive and: [(class lookupMethod: #printOn:) == (Object>>#printOn:) and: [(class lookupMethod: #printString) == (Object>>#printString)]]])
						ifTrue: [class basicNew printString]
						ifFalse: [self _recoveredProxiedObject printString]]]
			ifFalse: 
				[self printString]]]
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> reStoreValue [

	^id reStoreValue
]

{ #category : #forwarding }
SSWDBObjectProxy >> sqlStringIn: anSSWSQLDialect [

	| stream |
	
	stream := anSSWSQLDialect sqlWriteStream.
	
	self writeSQLOn: stream.
	
	^stream contents

]

{ #category : #forwarding }
SSWDBObjectProxy >> unstore [

	"Unstore the receiver's proxiedObject, returning the proxiedObject.
	This method handles the unstore of both unreferenced and referenced proxies (the latter invoked from Object>>unstore).

	NB: This is also a legacy selector whose meaning was 'unstore in the active transaction'.
	We have repurposed this to also be a direct 'unstore now' message, which begins and completes in its own transaction.
	Accomodate both new and legacy behavior by checking if there is currently a transaction in progress"
	
	^self _dbProxyReStore
	ifNil: 
		[self unstore]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[| me him |
			self isDBProxy
			ifTrue: 
				[self _recoveredProxiedObject isDBDeleted ifTrue: [^self].

				"This method handles unstores initiated from the proxied object so check if we've already been swapped"
				self _isSwapped 
				ifTrue: 
					[proxyReStore isTransactionInProgress ifFalse: [^proxiedObject unstored storeIn: proxyReStore].
					me := self.
					him := proxiedObject]
				ifFalse: 
					[proxyReStore isTransactionInProgress ifFalse: [^self unstored storeIn: proxyReStore].
					me := proxiedObject.
					him := self. 
					self _referenced].

				me _unstore.
				him]
			ifFalse: 
				[self unstore]]]
]

{ #category : #forwarding }
SSWDBObjectProxy >> unstored [

	"Return the receiver in an UnstoreWrapper"

	^SSWDBUnstoreWrapper on: self
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> writeSQLOn: aStream [

	"The SQL for a persistent object is its id"

	id writeSQLOn: aStream
]

{ #category : #'non forwarding' }
SSWDBObjectProxy >> writeSQLOn: aStream forCondition: aSQLCondition [

	^self writeSQLOn: aStream forField: aSQLCondition field
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> writeSQLOn: aStream forField: aField [

	"The SQL for a persistent object is its id"

	id writeSQLOn: aStream forField: aField
]
