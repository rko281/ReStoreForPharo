Extension { #name : #Object }

{ #category : #'*SSW ReStore Main' }
Object >> _changedObjectsIn: aReStore [

	^(self _checkHasChangedIn: aReStore)
		ifTrue: [Array with: self]
		ifFalse: [#()]
]

{ #category : #'*SSW ReStore Main' }
Object >> _checkHasChangedIn: aReStore [

	"Assuming the receiver is (or will be) a persistent object in aReStore, has it changed from the persisted version?"

	"Redirect to the proxy"
	^(self _dbProxyIn: aReStore ifNone: [nil])
		ifNil: [self isValidForPersistence not] "since a commit of a non-valid (i.e. non-base class) object will result in a write (insert)"
		ifNotNil: [ :proxy | proxy _checkHasChangedIn: aReStore]
]

{ #category : #'*SSW ReStore Main' }
Object >> _commitIn: aReStore [

	"Should only be sent when all proxied objects have been swapped out to their proxy,
	therefore the receiver is not currently persistent, therefore store it"

	"...however if the object is encountered multiple times during a commitObjects: operation, its proxy will have flipped to the object"
	(aReStore isInCurrentTransaction: self) ifFalse: 
		"isValidForPersistence test excludes base object types (String, Number etc.)"
		[self isValidForPersistence ifFalse: [self storeIn: aReStore]]
]

{ #category : #'*SSW ReStore Main' }
Object >> _dbProxy [

	"Attempt to locate the SSWDBObjectProxy wrapping this object.
	Error if none can be found (i.e. the receiver is not persistent)"
	
	^self _dbProxyIfNone: [self error: 'Cannot locate ReStore proxy']
]

{ #category : #'*SSW ReStore Main' }
Object >> _dbProxyIfNone: aBlock [

	"Attempt to locate the SSWDBObjectProxy wrapping this object.
	Return the value of aBlock if none can be found (i.e. the receiver is not persistent)"
	
	^SSWReStore proxyForObject: self ifNone: aBlock
]

{ #category : #'*SSW ReStore Main' }
Object >> _dbProxyIn: aReStore [

	^self _dbProxyIn: aReStore ifNone: [self error: 'Cannot locate ReStore proxy']
]

{ #category : #'*SSW ReStore Main' }
Object >> _dbProxyIn: aReStore ifNone: aBlock [
	
	^aReStore actualProxyForObject: self ifNone: aBlock
]

{ #category : #'*SSW ReStore Main' }
Object >> _ensureActiveIn: anSSWReStore [

	"Ensure that the receiver is 'active' in the given ReStore 
	'active' means persistent in anSSWReStore, and present in the current transaction.

	If this message is received by a real object it is either not persistent, or persistent and active.
	Hence - only need to ensure persistence"
	
	self _ensurePersistentIn: anSSWReStore
]

{ #category : #'*SSW ReStore Main' }
Object >> _ensurePersistentIn: anSSWReStore [

	"Ensure that the receiver is persistent in the given ReStore"

	self isValidForPersistence ifFalse:
		[anSSWReStore locateProxyForObject: self ifNone: [self storeIn: anSSWReStore]]
]

{ #category : #'*SSW ReStore Main' }
Object >> _forceRefreshIn: aReStore [

	"Private - Non-persistent - cannot have changed - do nothing"

	^self

]

{ #category : #'*SSW ReStore Main' }
Object >> _forceRefreshWithContents [

	"Private - Non-persistent - cannot have changed - do nothing.
	Return the refreshed contents (i.e. none)"

	^#()
]

{ #category : #'*SSW ReStore Main' }
Object >> _hasChangedFrom: anObject [

	"Return a Boolean indicating whether the receiver has changed in state from anObject.
	Default test - is it equal? 
	Subclasses with other definitions of 'state' should override"

	self == anObject ifTrue: [^false].
	
	^self isValidForPersistence 
		ifTrue: [self ~= anObject]
		ifFalse: [true]
]

{ #category : #'*SSW ReStore Main' }
Object >> _id [

	"Return the receiver's unique ID or nil if not persistent"

	^(self _dbProxyIfNone: [nil]) ifNotNil: [ :proxy | proxy _id]
]

{ #category : #'*SSW ReStore Main' }
Object >> _idIn: aReStore [

	"Return the receiver's unique ID as a proxy in the given ReStore instance"
	
	^(self _dbProxyIn: aReStore) _id
]

{ #category : #'*SSW ReStore Main' }
Object >> _isRecovered [

	"The receiver is a real object, therefore it is recovered from the database
	(compared to an unrecovered proxy - we do not consider the case where the receiver is non-persistent)"

	^true
]

{ #category : #'*SSW ReStore Main' }
Object >> _reStore [

	"Attempt to locate the SSWReStore in which the receiver resides.
	Return nil if none can be found (i.e. the receiver is not persistent)"

	^self _reStoreIfNone: [nil]
]

{ #category : #'*SSW ReStore Main' }
Object >> _reStoreIfNone: aBlock [

	"Attempt to locate the SSWReStore in which the receiver resides.
	Return the result of aBlock if none can be found (i.e. the receiver is not persistent)"

	^SSWReStore reStoreForObject: self ifNone: aBlock
]

{ #category : #'*SSW ReStore Main' }
Object >> _refreshIfUpdatedIn: aReStore [

	"Private - Non-persistent - cannot have been updated externally - do nothing"

	^self

]

{ #category : #'*SSW ReStore Main' }
Object >> _refreshIn: aReStore [

	"Private - Non-persistent - cannot have changed - do nothing"

	^self

]

{ #category : #'*SSW ReStore Main' }
Object >> _refreshWithContents [

	"Private - Non-persistent - cannot have changed - do nothing.
	Return the refreshed contents (i.e. none)"

	^#()
]

{ #category : #'*SSW ReStore Main' }
Object >> _refreshWithContentsIfUpdated [

	"Private - Non-persistent - cannot have changed - do nothing.
	Return the refreshed objects (i.e. none)"

	^#()
]

{ #category : #'*SSW ReStore Main' }
Object >> _rollbackIn: aReStore [

	"Should only be sent when all proxied objects have been swapped out to their proxy,
	therefore the receiver is not currently persistent, therefore do nothing"
]

{ #category : #'*SSW ReStore Main' }
Object >> _touch [

	"No-op to ensure the receiver (a persistent object) has been encountered during the current ReStore transaction"
]

{ #category : #'*SSW ReStore Main' }
Object >> errorNotPersistent [

	self error: 'object not persistent'
]

{ #category : #'*SSW ReStore Main' }
Object >> handleUpdateClash: aSymbol from: oldVersion to: newVersion [

	"A change in the receiver to the instance variable named aSymbol 
	has clashed with a change made in the database.
	oldVersion is a copy of the receiver as it was prior to its current updates.
	newVersion is a copy of the receiver as it currently is in the database.
	Analyse changes between the three versions (old, self and new)
	and attempt to bring the receiver up to date with newVersion,
	whilst maintaining changes from oldVersion.

	Return true if the receiver was able to resolve the conflict, false otherwise.
	Default - just return false

	Note that, in order to avoid disrupting the transaction commit mechanism,
	this method is always called the error-trapped safeHandleUpdateClash:...
	and so will never cause a walkback - a notification will be logged however"

	^false
]

{ #category : #'*SSW ReStore Main' }
Object >> hasChanged [

	"Return whether the receiver or its related objects have changed in the image since loading from the ReStore instance in which they reside"

	^(self _reStoreIfNone: ["Not (yet) persistent" ^true]) hasChanged: self withRelatedComponents
]

{ #category : #'*SSW ReStore Main' }
Object class >> instanceFromDBValue: aValue in: anSSWReStore [

	"Return an instance of the receiver class that is specified by the given value/ReStore combination.
	Default implementation for persistent application classes - query the ReStore for the relevant instance.
	Base classes (Integer, String etc.) should reimplement as appropriate"
	
	^aValue isNil
		ifTrue: [nil]
		ifFalse: [anSSWReStore deferredObjectOfClass: self withID: aValue]
]

{ #category : #'*SSW ReStore Main' }
Object >> isDBDeleted [

	^false
]

{ #category : #'*SSW ReStore Main' }
Object >> isDBProxy [

	"Differentiate between proxys and actual objects"

	^false
]

{ #category : #'*SSW ReStore Main' }
Object >> isPersistent [

	^(self _dbProxyIfNone: [nil]) notNil
]

{ #category : #'*SSW ReStore Main' }
Object >> isValidForPersistence [

	"Return a Boolean indicating whether the receiver is a valid object for persistent storage.
	Default - the basic types (Numbers, Strings etc.) are so valid"
	
	^self class isPersistentBaseClass
]

{ #category : #'*SSW ReStore Main' }
Object >> mergeUpdate: aSymbol from: anObject [

	"Transaction commit concurrent update resolution:
	The inst var of the receiver named aSymbol has changed in anObject (another version of the receiver).
	The receiver itself has NOT changed this inst var, but has changed other inst var(s).

	Handle the change and return whether a Boolean indicating if is was successfully handled,
	e.g. always return false to turn off auto merging.
	OR return nil to accept default handling (merge the change into the receiver)"

	^nil
]

{ #category : #'*SSW ReStore Main' }
Object >> mergeUpdateFrom: newVersion newValue: newValue accessor: anInstVarAccessor [

	"Private - Transaction commit concurrent update resolution:
	The value of inst var of the receiver accessed by anInstVarAccessor has been changed 
	to newValue in newVersion (a new version of the receiver from the database).
	The receiver itself has NOT changed this inst var, but has changed other inst var(s).

	Handle the change and return whether is was successfully handled.
	Default handling is just to merge the change into the receiver"

	"This method is essentially private; pass to a simplified handler which subclasses can override"
	^(self mergeUpdate: anInstVarAccessor name from: newVersion) ifNil: 
		["Default handling"
		anInstVarAccessor value: newValue in: self.
		true]
]

{ #category : #'*SSW ReStore Main' }
Object >> onAboutToUnstore [

	"The receiver is about to be unstored from its ReStore container - carry out any necessary actions.
	Note in the event of a commit failure (e.g. update clash) the unstore may be rolled back.
	Use onUnstored for definite confirmation of a completed unstore"
]

{ #category : #'*SSW ReStore Main' }
Object >> onRefresh [

	"Carry out any actions necessary following refreshing this Object from the database.
	Default - do nothing"
]

{ #category : #'*SSW ReStore Main' }
Object >> onRollback [

	"Carry out any actions necessary following rolling back this object to its state prior to the current transaction.
	Default - do nothing"

]

{ #category : #'*SSW ReStore Main' }
Object >> onUnstored [

	"The receiver has been unstored from the database.
	Carry out any necessary actions"
]

{ #category : #'*SSW ReStore Main' }
Object class >> preferredObjectProxyClass [ 

	"If the receiver needs a specific proxy class, return this else nil"

	^nil
]

{ #category : #'*SSW ReStore Main' }
Object >> reStoreValue [

	"Return an object to use to represent the receiver in ReStore.
	Default - use the receiver, or unique ID if not directly valid for persistence.
	May be overriden where requirements differ"
	
	^self isValidForPersistence 
		ifTrue: [self] 
		ifFalse: [self _id reStoreValue]
]

{ #category : #'*SSW ReStore Main' }
Object >> refresh [

	"Refresh the receiver and its related objects to their stored state"

	(self _reStoreIfNone: [self errorNotPersistent]) refresh: self withRelatedComponents
]

{ #category : #'*SSW ReStore Main' }
Object >> rollback [

	"Rollback the receiver and its related objects to their previous state"

	(self _reStoreIfNone: [self errorNotPersistent]) rollback: self withRelatedComponents
]

{ #category : #'*SSW ReStore Main' }
Object >> safeHandleUpdateClash: aSymbol from: oldVersion to: newVersion [

	"Private - Error-trapped entrypoint for handleUpdateClash:from:to:
	Trap any error during the clash resolution and re-raise as a notification"

	| result |

	result := 
		[self handleUpdateClash: aSymbol from: oldVersion to: newVersion]
			on:	Error
			do:	[ :exc | 
				exc resignalAs: 
					(Notification new messageText: 
						('Error: ', exc description, 
						' signalled during #handleUpdateClash:from:to: for ',
						([self debugPrintString] 
							on: Error do: [:e | 'an invalid ', self basicClass name])))].

	^result = true
]

{ #category : #'*SSW ReStore Main' }
Object >> safeMergeUpdateFrom: newVersion newValue: anObject accessor: anInstVarAccessor [

	"Private - Error-trapped entrypoint for mergeUpdateFrom:newValue:accessor:
	Trap any error during the merge and re-raise as a notification"

	| result |

	result := 
		[self mergeUpdateFrom: newVersion newValue: anObject accessor: anInstVarAccessor]
			on:	Error
			do:	[ :exc | 
				exc resignalAs: 
					(Notification new messageText: 
						('Error: ', exc description, 
						' signalled during #mergeUpdateFrom:newValue:accessor: for ',
						([self debugPrintString] 
							on: Error do: [:e | 'an invalid ', self basicClass name])))].

	^result = true
]

{ #category : #'*SSW ReStore Main' }
Object >> similarInstances [

	^self similarInstancesIn: SSWReStore default
]

{ #category : #'*SSW ReStore Main' }
Object >> similarInstancesIn: aReStore [

	"Return an InstancesCollection representing those persistent instances
	which are similar to the receiver (a 'template' instance)"

	| instances |

	instances := aReStore instancesOf: self class.
	self qualify: instances in: aReStore via: OrderedCollection new.

	^instances
]

{ #category : #'*SSW ReStore Main' }
Object >> store [

	"Store the receiver and its related objects in the ReStore instance in which they reside (or the default if not currently persistent); return success.
	In the event of a failure the default action is to abandon the failed transaction leaving the receiver in its current state. 
	To handle transaction failure manually (e.g. to rollback and refresh) trap StoreFailure"

	^self storeIn: (self _reStoreIfNone: [SSWReStore default])
]

{ #category : #'*SSW ReStore Main' }
Object >> storeIn: aReStore [

	"Store the receiver and its related objects in aReStore; return success.
	In the event of a failure the default action is to abandon the failed transaction leaving the receiver in its current state. 
	To handle transaction failure manually (e.g. to rollback and refresh) trap StoreFailure.

	NB: This is also a legacy selector whose meaning was 'store in the active transaction'.
	We have repurposed this to also be a direct 'store now' message, which begins and completes in its own transaction.
	Accomodate both new and legacy behavior by checking if there is currently a transaction in progress"

	^(aReStore isTransactionInProgress and: [(self _dbProxyIn: aReStore ifNone: [nil]) isNil])
	ifTrue: 
		[self storeInAnsweringProxy: aReStore.
		self]
	ifFalse:
		[(aReStore commit: self withRelatedComponents)
			ifTrue: [true]
			ifFalse: [StoreFailure signalWith: aReStore. false]]
]

{ #category : #'*SSW ReStore Main' }
Object >> storeInAnsweringProxy: anSSWReStore [

	"Store the receiver object as a new persistent object in anSSWReStore.
	Return the new proxy (intended for privileged code only)"
	
	| proxy |

	proxy := anSSWReStore createProxyForNewObject: self.

	proxy _referenced.

	^proxy
]

{ #category : #'*SSW ReStore Main' }
Object class >> storedInstances [

	"Return all instances of the receiver stored in the database accessed by the default ReStore"

	^self storedInstancesIn: SSWReStore default
]

{ #category : #'*SSW ReStore Main' }
Object class >> storedInstancesIn: aReStore [

	"Return all instances of the receiver stored in the database accessed by aReStore"

	^aReStore instancesOf: self
]

{ #category : #'*SSW ReStore Main' }
Object >> unstore [

	"Unstore the receiver and its dependent objects from the ReStore in which they reside.

	NB: This is also a legacy selector whose meaning was 'unstore in the active transaction'.
	We have repurposed this to also be a direct 'unstore now' message, which begins and completes in its own transaction.

	Accomodate both new and legacy behavior by checking if there is currently a transaction in progress"

	^(self _dbProxyIfNone: [nil]) ifNotNil: 
		[ :proxy |
		proxy _reStore isTransactionInProgress 
			ifTrue: [proxy _unstore "Legacy"]
			ifFalse: [self unstored store] "New behavior"]
]

{ #category : #'*SSW ReStore Main' }
Object >> unstored [

	"Return the receiver in an UnstoreWrapper"

	^SSWDBUnstoreWrapper on: self
]

{ #category : #'*SSW ReStore Main' }
Object >> withComponents [

	^SSWDBObjectWithComponents on: self
]

{ #category : #'*SSW ReStore Main' }
Object >> withRelatedComponents [

	^SSWDBObjectWithRelatedComponents on: self
]

{ #category : #'*SSW ReStore Main' }
Object >> writeSQLOn: aStream [

	"Defer to printOn: by default"
	^self printOn: aStream
]
