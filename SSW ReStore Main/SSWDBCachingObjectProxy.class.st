"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCachingObjectProxy,
	#superclass : #SSWDBObjectProxy,
	#instVars : [
		'copyObject'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _aquireCollectionProxiesUsing: collectionSpecs [

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
			spec accessor value: (collectionProxies at: spec) in: proxiedObject.
			copyObject notNil ifTrue: 
				[spec accessor value: (collectionProxies at: spec) in: copyObject]]]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _aquireCopyObject [

	copyObject := self _dbTable copyForProxy: proxiedObject
]

{ #category : #testing }
SSWDBCachingObjectProxy >> _checkHasChanged [

	"Use the copy object to determine these"
	
	^self _isDeleted or:
		[self _isNew or: 
			[self _dbTable dataFields anySatisfy:
				[ :field || accessor current |
				accessor := field accessor.
				current := accessor valueIn: proxiedObject.
				current _hasChangedFrom: (accessor valueIn: copyObject)]]]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _commitChanges [

	"Return a Boolean indicating whether the commit succeeds"

	^self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [reStore deleteProxy: self. true]
			ifFalse: [self _commitUpdates]]
	ifFalse:
		[reStore insertProxy: self.
		true]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _commitUpdates [

	"Return a Boolean indicating whether the commit succeeds"

	| updates |

	updates := self _fieldUpdates.
	
	^updates isEmpty 
		ifTrue: [true]
		ifFalse: [reStore applyUpdates: updates toObject: self]
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _copyObject [

	"The receiver automatically detects changes to its proxiedObject by maintaining a shallow copy
	of the proxiedObject. This is held in copyObject"
	
	^copyObject
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _copyObject: anObject [

	"The receiver automatically detects changes to its proxiedObject by maintaining a shallow copy
	of the proxiedObject. This is held in copyObject"
	
	copyObject := anObject
]

{ #category : #evaluating }
SSWDBCachingObjectProxy >> _fieldUpdates [

	"Use the copy object to determine these"
	
	^self _dbTable dataFields inject: SSWSQLFieldAssignmentCollection new into: 
		[ :updates :field || accessor current |
		accessor := field accessor.
		current := accessor valueIn: proxiedObject.
		(current _hasChangedFrom: (accessor valueIn: copyObject)) ifTrue: 
			[updates add: (SSWSQLFieldAssignment field: field value: current)].
		updates]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _forgetProxiedObject [

	"Override to reset the copyObject"
	
	copyObject := nil.
	^super _forgetProxiedObject
]

{ #category : #testing }
SSWDBCachingObjectProxy >> _isDeleted [

	"Return a Boolean indicating whether the receiver has been marked as deleted..
	Deleted proxies have a copyObject, but no proxiedObject"
	
	^copyObject ~~ nil and: [proxiedObject == nil]
]

{ #category : #testing }
SSWDBCachingObjectProxy >> _isPersistent [

	"Return a Boolean indicating whether the receiver is persistent.
	Persistent proxies always have a copyObject, if they are recovered.
	Unrecovered proxies are persistent by definition"
	
	^copyObject ~~ nil or: [self _isRecovered not]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _matchStateOf: aProxy [

	"Match the internal proxy (non data) state of aProxy"

	^self
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _postCommitChanges [

	"The receiver's changes have successfully been committed.
	Complete follow-on work"

	^self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [self _postCommitDelete]
			ifFalse: [self _postCommitUpdates]]
	ifFalse:
		[self _dbTable idDataField ifNotNil: [ :idDataField | idDataField accessor value: id in: proxiedObject].
		self _aquireCopyObject.
		self _intern	"Re-register"]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _postCommitDelete [

	"The receiver has been successfully deleted from the database.
	Complete follow-on work and notify interest parties"

	reStore uncacheObject: self. 

	proxiedObject onUnstored.

	copyObject := proxiedObject := SSWDBDeletedObject newForClass: class id: id.
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _postCommitUpdates [

	| updates |

	updates := self _fieldUpdates.
	
	updates isEmpty ifFalse: [updates applyTo: copyObject]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _prepareToCommit [

	"Intercept to check for overwriten dependent objects - unstore these (issue#0006)"

	(self _isPersistent and: [self _isDeleted not]) ifTrue:
		[| replacedDependentFields |
		replacedDependentFields := self _dbTable dependentDataFieldsSelect:
			[ :field | (field accessor valueIn: proxiedObject) ~~ (field accessor valueIn: copyObject)].
		replacedDependentFields isEmpty ifFalse:
			[| heldObjects |
			"Only delete replaced dependent objects if they are not held elsewhere in proxiedObject"
			heldObjects := self _dbTable dataFields collect: [ :field | field accessor valueIn: proxiedObject].
			replacedDependentFields do: 
				[ :field | 
				(heldObjects identityIncludes: (field accessor valueIn: copyObject)) ifFalse:
					[(field accessor valueIn: copyObject) unstore]]]].

	^super _prepareToCommit
]

{ #category : #accessing }
SSWDBCachingObjectProxy >> _proxiedObject: anObject [

	"Overriden to set the copyObject"
	
	super _proxiedObject: anObject.
	self _aquireCopyObject
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _recoverProxiedObject [

	"Override to check for deleted status"
	
	self _isDeleted ifTrue: [nil error: 'Attempt to reference deleted persistent object'].
	
	super _recoverProxiedObject
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _refreshAndRollforward [

	"Apply the changes made to the receiver to the current representation in the DB.
	Return a Boolean indicating if the receiver should be re-commited"

	| currentProxy |

	currentProxy := self _currentVersion.

	^(self _refreshAndRollforwardFrom: currentProxy)
		ifTrue: [self _matchStateOf: currentProxy. true]
		ifFalse: [false]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _refreshAndRollforwardFrom: currentProxyObject [

	"Update the receiver such that it is based on the state of currentProxyObject
	with its own changes (compared to copyObject) applied on top.
	Return a Boolean indicating if the receiver should be re-commited"

	| currentObject |

	currentObject := currentProxyObject _proxiedObject.

	^self _isDeleted
	ifTrue:
		[currentObject isDBDeleted 
			ifTrue: [false]
			ifFalse: [true]]
	ifFalse:
		[currentObject isDBDeleted
		ifTrue:
			["Re-insert the receiver by marking it as new"
			copyObject := nil.
			currentProxyObject _matchStateOf: self]
		ifFalse:
			[| myUpdates |
			myUpdates := self _fieldUpdates.
			currentProxyObject _copyObject: copyObject.
			currentProxyObject _fieldUpdates applyTo: proxiedObject.
			myUpdates applyTo: proxiedObject].
		true]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _refreshFromRow: aDatabaseRow table: aDBTable [

	"Return whether the proxiedObject was refreshed at all.
	table is passed in as an optimisation"

	^(super _refreshFromRow: aDatabaseRow table: aDBTable)
	ifTrue: 
		["Update the copyObject"
		self _aquireCopyObject]
	ifFalse:
		[false]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _resolveUpdateConflicts [

	"Changes to the receiver have failed to commit in anSSWReStore due to another client's changes.
	Attempt to resolve the conflicts.

	For implementation details, see _resolveUpdateConflictsWith:"	

	| currentProxy |

	currentProxy := self _currentVersion.

	^(self _resolveUpdateConflictsWith: currentProxy)
		ifTrue: [self _matchStateOf: currentProxy. true]
		ifFalse: [false]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _resolveUpdateConflictsWith: currentProxyObject [

	"Changes to the receiver have failed to commit in anSSWReStore due to another client's changes.
	Analyse all changes made (between the receiver's copyObject, proxiedObject and currentProxyObject)
	and attempt to bring the receiver up to date with the state of currentProxyObject,
	whilst maintaining the receiver's changes from its copyObject.

	Return true if the receiver was able to resolve the conflict, false otherwise"

	| newVersion |

	newVersion := currentProxyObject _proxiedObject.
	newVersion isDBDeleted ifTrue: [^false].

	self _dbTable dataFields do:
		[ :field || accessor oldValue myValue newValue |
		accessor := field accessor.
		oldValue := accessor valueIn: copyObject.
		myValue := accessor valueIn: proxiedObject.
		newValue := accessor valueIn: newVersion.

		(myValue _hasChangedFrom: oldValue) 
		ifTrue: 
			["Receiver has changed this attribute.
			If newVersion has also changed it, then there is a clash.
			Ask the proxiedObject to resolve this"
			(newValue _hasChangedFrom: oldValue) ifTrue:
				[(proxiedObject 
					safeHandleUpdateClash: accessor name 
					from: copyObject
					to: newVersion) ifFalse: [^false]]]
		ifFalse:
			["Receiver has not changed this attribute (no clash). 
			Check for change in newVersion, and ask proxiedObject to handle it (usually by merging)"
			(newValue _hasChangedFrom: oldValue) ifTrue: 
				[(proxiedObject 
					safeMergeUpdateFrom: newVersion 
					newValue: newValue
					accessor: accessor) ifFalse:[^false]]]].

	^true
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _rollbackChanges [

	self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [self _rollbackUnstore]
			ifFalse: [self _rollbackUpdates]]
	ifFalse:
		[self _rollbackStore]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _rollbackStore [

	"The receiver was a newly-persisted object - deregister from the reStore"

	reStore deregisterProxy: self
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _rollbackUnstore [

	self 
		_proxiedObject: copyObject;
		_swapReferences
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _rollbackUpdates [

	"Forget any updates by instantiating from the copyObject.
	Also transfer over any events registered against the current proxiedObject"

	| me him |

	me := proxiedObject.
	him := self.

	self _swapReferences.

	me _checkHasChanged ifTrue: 
		[me _proxiedObject: me _copyObject shallowCopy. 
		him getEvents ifNotNil: [ :events | me _proxiedObject setEvents: events]]
]

{ #category : #'actions-internal' }
SSWDBCachingObjectProxy >> _unstore [

	"Intercept this message in order to point references to the proxiedObject
	to the copyObject - this enables identity to be preserved in the event of a rollback"

	| object |

	self _isPersistent ifTrue: [object := proxiedObject].	
	super _unstore.

	object isNil ifFalse:
		["Temporarily reset the proxiedObject to swap refs"
		proxiedObject := object.
		copyObject := proxiedObject become: copyObject.
		proxiedObject := nil]
]

{ #category : #forwarding }
SSWDBCachingObjectProxy >> inspect [

	"Prevent inspecting of a deleted object"

	^self _isDeleted
		ifTrue: [nil inspect]
		ifFalse: [super inspect]
]
