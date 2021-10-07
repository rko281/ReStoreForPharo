"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
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

{ #category : #constants }
SSWDBObjectProxy class >> modifyUpdatesFor: anSSWDBTable [

	"Return any updates that should be applied to rows in anSSWDBTable when carrying out a modify: update.

	None by default, subclasses should override as necessary"

	^OrderedCollection new
]

{ #category : #forwarding }
SSWDBObjectProxy >> = anotherObject [

	"No need to fetch the object if #= == #=="
	^(proxiedObject isNil and: [(class lookupMethod: #=) == (Object>>#=)])
		ifTrue: [self == anotherObject]
		ifFalse: [self doesNotUnderstand: (Message selector: #= arguments: (Array with: anotherObject))]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _aquireCollectionProxiesUsing: collectionSpecs [

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
		[collectionSpecs do:
			[ :spec |
			spec accessor value: (collectionProxies at: spec) in: proxiedObject]]
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
SSWDBObjectProxy >> _postSwapReferences [

	"Inform the collectionProxies"

	collectionProxies do: [ :proxy | proxy _owner: self]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _prepareToCommit [

	self _isDeleted ifFalse: 
		[reStore preWriteValidate: self]
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _proxiedObjectMissing [

	"The receiver's proxiedObject (as specified by class/id) is missing.
	Initialize the receiver to represent this"

	self 
		_proxiedObject: (SSWDBDeletedObject newForClass: class id: id);
		_collectionProxies: IdentityDictionary new
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

{ #category : #accessing }
SSWDBObjectProxy >> _unrecoveredProxyString [

	^'%<an unrecovered <1p> id=<2p>%>' expandMacrosWith: class with: id
]

{ #category : #'actions-internal' }
SSWDBObjectProxy >> _unstore [

	"Unstore the receiver's proxyObject - set the receiver's state so that the receiver is recognised as unstored and hence will be deleted at the next commit"

	"Notify interested parties"
	self _dbTable aboutToBeUnstored: proxiedObject.
	proxiedObject onAboutToUnstore.

	self _isPersistent 
		ifTrue: [self __referenced]
		ifFalse: [reStore deregisterProxy: self; removeFromTransaction: self].

	"Separate loops to cope with potential reference swap"
	collectionProxies do: [ :each | each __ensureActive].
	collectionProxies do: [ :each | each _unstore].

	proxiedObject := nil
]

{ #category : #forwarding }
SSWDBObjectProxy >> basicClass [

	^class
]

{ #category : #forwarding }
SSWDBObjectProxy >> class [

	"No need to bother the proxiedObject, except for inherited objects which are needed to determine their class"

	^(self _dbTable class == SSWDBTable) 
	ifTrue: 
		[class]
	ifFalse: 
		[proxiedObject == nil ifTrue: [self _recoverProxiedObject].
		proxiedObject class]
]

{ #category : #'accessing:derived' }
SSWDBObjectProxy >> currentVersion [

	"Re-read the receiver's proxiedObject from the database,
	returning it as a new unproxied object.
	c.f. _currentVersion which returns a proxied object"
	
	^self _currentVersion _proxiedObject
]

{ #category : #forwarding }
SSWDBObjectProxy >> debugPrintString [

	"Override to test for deleted status"
	
	^self _isDeleted 
		ifTrue: [(SSWDBDeletedObject newForClass: class id: id) printString]
		ifFalse: [super debugPrintString]
]

{ #category : #forwarding }
SSWDBObjectProxy >> hash [

	"No need to fetch the object if hash == identityHash"

	^(proxiedObject isNil and: [(class lookupMethod: #hash) == (Object>>#hash)])
		ifTrue: [self identityHash]
		ifFalse: [self doesNotUnderstand: (Message selector: #hash)]
]

{ #category : #forwarding }
SSWDBObjectProxy >> isInteger [

	"No need to bother the proxiedObject"
	
	^false

]

{ #category : #forwarding }
SSWDBObjectProxy >> isKindOf: aClass [

	"No need to bother the proxiedObject (except for inherited objects)"

	^(self _dbTable class == SSWDBTable)
	ifTrue: 
		[(class == aClass) or: [class inheritsFrom: aClass]]
	ifFalse: 
		[proxiedObject == nil ifTrue: [self _recoverProxiedObject].
		proxiedObject isKindOf: aClass]
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

	^self _isDeleted
		ifTrue: [aStream nextPutAll: self debugPrintString]
		ifFalse: [super printOn: aStream]
]

{ #category : #forwarding }
SSWDBObjectProxy >> printString [

	"Do not error on printString to a deleted object"

	^self _isDeleted
		ifTrue: [self debugPrintString]
		ifFalse: [super printString]
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
	This message (as opposed to the private _unstore) is only sent when the receive has not yet been referenced in the current transaction. Hence reference it here.

	NB: This is also a legacy selector whose meaning was 'unstore in the active transaction'.
	We have repurposed this to also be a direct 'unstore now' message, which begins and completes in its own transaction.
	Accomodate both new and legacy behavior by checking if there is currently a transaction in progress"
	
	| me him |

	reStore isTransactionInProgress ifFalse: [^self unstored store].

	proxiedObject == nil ifTrue: [self _recoverProxiedObject].
	proxiedObject isDBDeleted ifTrue: [^self].

	"Set me and him to be correct after the swap (done during _referenced)"
	me := proxiedObject.
	him := self.

	self _referenced.

	me _unstore.

	^him
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
