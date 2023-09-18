"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBProxy,
	#superclass : #SSWDBProtoObject,
	#instVars : [
		'proxiedObject',
		'reStore',
		'flags'
	],
	#classVars : [
		'IsDeletedMask',
		'IsPersistentMask',
		'IsSwappedMask'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'class initialization' }
SSWDBProxy class >> initialize [

	IsSwappedMask := 1.
	IsPersistentMask := 2.
	IsDeletedMask := 4
]

{ #category : #'instance creation' }
SSWDBProxy class >> new [

	"Create and answer a new instance of the receiver.
	By default we assume the instance will be used for a persistent object; other users should send _setNewNonPersistent after creation"

	^super new
		_flags: IsPersistentMask;
		yourself
]

{ #category : #'actions-internal' }
SSWDBProxy >> __ensureActive [

	"Check if the receiver is in its reStore's current transaction. If not, add it to the transaction

	c.f. _ensureActiveIn:, which is a distinct method sent only by objects external to the proxy mechanism.
	__ensureActive is sent internally within the proxy mechanism, 
	hence the receipt of the message cannot be taken as a guarantee of non-activity"
	
	proxiedObject == nil ifTrue: [self _recoverProxiedObject].

	(reStore transaction includesProxy: self) ifFalse: [self _referenced]
]

{ #category : #accessing }
SSWDBProxy >> __proxiedObject: anObject [

	"Private - Guaranteed direct assignment with no additional functionality - do not override"
	
	proxiedObject := anObject
]

{ #category : #'actions-internal' }
SSWDBProxy >> __referenced [

	reStore proxy: self forwarded: (Message selector: #_referenced)
]

{ #category : #accessing }
SSWDBProxy >> _changedObjectsIn: aReStore [

	^(self _checkHasChangedIn: aReStore)
		ifTrue: [Array with: self]
		ifFalse: [#()]
]

{ #category : #testing }
SSWDBProxy >> _checkHasChanged [

	"Return whether the receiver's proxiedObject has been changed 
	from its representation in the database.

	Compared to _hasChanged, the inferrence is that this is a 'quick test',
	not related to commiting those changes"
	
	^self subclassResponsibility
]

{ #category : #testing }
SSWDBProxy >> _checkHasChangedIn: aReStore [

	^self _isRecovered and: [self _hasChanged]
]

{ #category : #'actions-internal' }
SSWDBProxy >> _clearDeleted [

	"Private - Clear deleted status"

	flags := flags maskClear: IsDeletedMask
]

{ #category : #'actions-internal' }
SSWDBProxy >> _commitChanges [

	"Commit to the reStore changes to the receiver's proxiedObject.
	Return a Boolean indicating success"
	
	self subclassResponsibility
]

{ #category : #'actions-internal' }
SSWDBProxy >> _commitChangesPhase1 [

	"Commit to the reStore changes to the receiver's proxiedObject - phase 1 of 2.
	Return a Boolean indicating success"

	"Default behaviour for subclasses only requiring a single phase"
	^self _commitChanges
]

{ #category : #'actions-internal' }
SSWDBProxy >> _commitChangesPhase2 [

	"Commit to the reStore changes to the receiver's proxiedObject - phase 2 of 2.
	Return a Boolean indicating success"

	"Subclasses only requiring a single phase should override _commitChanges"
	^true
]

{ #category : #'actions-internal' }
SSWDBProxy >> _commitIn: anSSWReStore [

	"Add the receiver to the referenced set (if it is recovered) for subsequent commit"

	self validateReStore: anSSWReStore.

	self _isRecovered ifTrue: [self _referenced]
]

{ #category : #'non forwarding' }
SSWDBProxy >> _dbProxyIfNone: aBlock [

	"Private - Received if the receiver has been swapped from a real object back to a proxy"

	^self
]

{ #category : #'accessing:direct' }
SSWDBProxy >> _dbProxyIn: aReStore [
	
	^self _dbProxyIn: aReStore ifNone: [self error: 'proxy does not belong to aReStore']
]

{ #category : #'accessing:direct' }
SSWDBProxy >> _dbProxyIn: aReStore ifNone: aBlock [
	
	^aReStore == reStore
		ifTrue: [self]
		ifFalse: [aBlock value]
]

{ #category : #accessing }
SSWDBProxy >> _dbProxyReStore [
	"Private - As #_reStore, but do not perform a reverse lookup if sent to a regular object.
	Used internally by #doesNotUnderstand: to safely retrieve the ReStore in order to enter a critical section.

	See implementation in Object for more details"

	^reStore
]

{ #category : #'non forwarding' }
SSWDBProxy >> _debugPrintString [

	"Do not fault the receiver just for a debugger"

	^proxiedObject == nil
		ifTrue: [self _unrecoveredProxyString]
		ifFalse: ['<', proxiedObject debugPrintString, '>']
]

{ #category : #'actions-internal' }
SSWDBProxy >> _ensureActiveIn: anSSWReStore [

	"Ensure that the receiver is 'active' in the given ReStore 
	'active' means persistent in anSSWReStore, and present in the current transaction.

	Since the message has been received by a proxy then we can sumise it is persistent, 
	but not active in the current transaction - reference it to arrange this"

	self validateReStore: anSSWReStore.

	proxiedObject == nil ifTrue: [self _recoverProxiedObject].

	self _referenced
]

{ #category : #'actions-internal' }
SSWDBProxy >> _ensurePersistentIn: anSSWReStore [

	"Check if the receiver is persistent in the given SSWReStore"
	
	"Proxies are persistent by default - only need check anSSWReStore"
	self validateReStore: anSSWReStore
]

{ #category : #accessing }
SSWDBProxy >> _flags [

	^flags
]

{ #category : #accessing }
SSWDBProxy >> _flags: aSmallInteger [

	flags := aSmallInteger
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _forceRefresh [

	"Simple - just forget then re-recover the proxied object"

	self 
		_lazyRefresh; 
		_recoverProxiedObject
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _forceRefreshIn: aReStore [

	self validateReStore: aReStore.

	self _forceRefresh
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _forceRefreshWithContents [

	"Refresh the receiver and its contents (if any). Return any refreshed contents (if any)"

	self _forceRefresh.

	^#()
]

{ #category : #'actions-internal' }
SSWDBProxy >> _forgetProxiedObject [

	"Dispose of the reference to the receiver's proxiedObject"
	
	proxiedObject := nil
]

{ #category : #accessing }
SSWDBProxy >> _frontFace [
	"Private - Answer the 'front face' identity associated with the receiver--the identity that should be referenced by other persisted objects.
	When the receiver is swapped, this is the proxiedObject.
	
	N.B. Must be called in a critical section."

	^self _isSwapped ifTrue: [self _proxiedObject] ifFalse: [self].
]

{ #category : #testing }
SSWDBProxy >> _hasChanged [

	"Return whether the receiver's proxiedObject has been changed
	from its representation in the database

	Compared to _checkHasChanged, the inferrence is that if the receiver has 
	actually changed, then the receiver will next be sent _prepareToCommit. 
	Subclasses may take advantage by caching some of the work done here"

	^self _checkHasChanged
]

{ #category : #testing }
SSWDBProxy >> _hasChangedFrom: anObject [

	^(self == anObject) not
]

{ #category : #testing }
SSWDBProxy >> _isDeleted [

	"Return a Boolean indicating whether the receiver is marked as deleted"
	
	^flags anyMask: IsDeletedMask
]

{ #category : #testing }
SSWDBProxy >> _isPersistent [

	"Return a Boolean indicating whether the receiver is persistent
	(has been written to the database yet)"
	
	^flags anyMask: IsPersistentMask
]

{ #category : #testing }
SSWDBProxy >> _isRecovered [

	^proxiedObject ~~ nil
]

{ #category : #testing }
SSWDBProxy >> _isSwapped [

	"Return a Boolean indicating whether the receiver has been swapped such that all references point to the proxiedObject.
	For speed this is usually inlined"

	^flags anyMask: IsSwappedMask
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _lazyRefresh [

	"Simple - just forget the proxied object"

	self _forgetProxiedObject
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _lazyRefreshIn: aReStore [

	self validateReStore: aReStore.

	self _lazyRefresh
]

{ #category : #accessing }
SSWDBProxy >> _newProxiedObject: anObject [

	"Set proxiedObject, but the implication is anObject is new, i.e. not yet persistent.
	Defer to _setProxiedlObject: by default; subclasses may override as necessary"
	
	self _setProxiedObject: anObject
]

{ #category : #'actions-internal' }
SSWDBProxy >> _postCommitChanges [

	"The receiver's changes have been successfully committed.
	Carry out any necessary internal updates"

	^self
]

{ #category : #'actions-internal' }
SSWDBProxy >> _postSwapReferences [

	"Carry out any tidying up actions required after a _swapReferences"

	^self
]

{ #category : #'actions-internal' }
SSWDBProxy >> _prepareToCommit [

	"Prepare to commit changes to the receiver's proxiedObject"
	
	self subclassResponsibility
]

{ #category : #'actions-internal' }
SSWDBProxy >> _prepareToCommitPhase1 [

	"Prepare to commit changes to the receiver's proxiedObject - pass 1 of 2.
	Answer true or false depending on whether the receiver needs phase 2 to complete its preparations"

	"Default action for subclasses only needing one pass"
	self _prepareToCommit.
	^false
]

{ #category : #'actions-internal' }
SSWDBProxy >> _prepareToCommitPhase2 [

	"Prepare to commit changes to the receiver's proxiedObject - pass 2 of 2."

	"Subclasses only requiring a single phase should override _prepareToCommit"
	^self
]

{ #category : #testing }
SSWDBProxy >> _proxiedClassIsDefinitive [

	"Private - Is the class of the proxied object definitively known?"

	^true
]

{ #category : #accessing }
SSWDBProxy >> _proxiedObject [

	"proxiedObject stores the actual object which the receiver is a proxy for"
	
	^proxiedObject
]

{ #category : #accessing }
SSWDBProxy >> _proxiedObject: anObject [

	"proxiedObject stores the actual object which the receiver is a proxy for"
	
	proxiedObject := anObject
]

{ #category : #accessing }
SSWDBProxy >> _proxiedObjectClass [

	"Answer the class of the proxiedObject (or best guess) without needing to have the proxiedObject itself"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBProxy >> _reStore [

	"reStore stores the SSWReStore which owns the object for which the receiver is a proxy"
	
	^reStore
]

{ #category : #accessing }
SSWDBProxy >> _reStore: anSSWReStore [

	"reStore stores the SSWReStore which owns the object for which the receiver is a proxy"
	
	reStore := anSSWReStore
]

{ #category : #'accessing:direct' }
SSWDBProxy >> _reStoreIfNone: aBlock [

	^reStore
]

{ #category : #'actions-internal' }
SSWDBProxy >> _recoverProxiedObject [

	"Recover the receiver's proxiedObject from the database"
	
	self subclassResponsibility
]

{ #category : #accessing }
SSWDBProxy >> _recoveredProxiedObject [

	"Answer the proxiedObject, recovering it from the database if necessary"

	proxiedObject isNil ifTrue: [self _recoverProxiedObject].
	^proxiedObject
]

{ #category : #'actions-internal' }
SSWDBProxy >> _referenced [

	"This message is sent by clients of the receiver which access the proxiedObject directly,
	but wish such accesses to be notified to interested parties in the same way as a DNU send.

	Carry out the same notifications as occur during the receiver's implementation of DNU"

	| me |

	"Unless the receiver is new, swap references to the receiver and proxiedObject.
	From hereon, must use me instead of self, and not reference inst vars directly"
	self _isPersistent
		ifTrue: [me := self _swap]
		ifFalse: [me := self].

	me __referenced.
	
	^me
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _refresh [

	"Refresh the receiver with its current database version according to its own preferred strategy.
	Default behaviour is to refresh if updated; future releases may make this choice tuneable or heuristic-driven based on class/instance etc."

	self _refreshIfUpdated
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _refreshIfUpdated [

	"Refresh the receiver if it has been updated in the database.

	Simplest implementation - just refresh regardless. More intelligent subclasses may do something better"

	self _forceRefresh
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _refreshIfUpdatedIn: aReStore [

	self validateReStore: aReStore.

	self _refreshIfUpdated
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _refreshIn: aReStore [

	self validateReStore: aReStore.

	self _refresh
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _refreshWithContents [

	"Refresh the receiver and its contents (if any). Return any refreshed contents (if any)"

	"Default behaviour is to only refresh if updated. Future releases may make this choice tuneable or heuristic-driven based on class/instance"
	^self _refreshWithContentsIfUpdated
]

{ #category : #'actions-refresh' }
SSWDBProxy >> _refreshWithContentsIfUpdated [

	"Refresh the receiver and its contents (if any) if they are updated. Return the refreshed contents (if any)"

	self _refreshIfUpdated.
	^#()
]

{ #category : #'actions-internal' }
SSWDBProxy >> _rollbackChanges [

	"Forget changes to the receiver.
	By default, this is done by forgetting about the proxiedObject (forcing a re-read)"
	
	self _forgetProxiedObject
]

{ #category : #'actions-internal' }
SSWDBProxy >> _rollbackIn: aReStore [

	"Add the receiver to the referenced set (if it is recovered) for subsequent rollback"

	self validateReStore: aReStore.

	self _isRecovered ifTrue: [self _referenced]
]

{ #category : #'actions-internal' }
SSWDBProxy >> _setDeleted [

	"Private - Set the receiver's state to mark it as deleted from the database (assuming the commit completes)"

	flags := flags maskSet: IsDeletedMask
]

{ #category : #'actions-internal' }
SSWDBProxy >> _setNewNonPersistent [

	"Initialize the receiver as a new non-persistent object"

	flags := (flags maskClear: IsPersistentMask) maskSet: IsSwappedMask
]

{ #category : #'actions-internal' }
SSWDBProxy >> _setNonPersistent [

	flags := flags maskClear: IsPersistentMask
]

{ #category : #'actions-internal' }
SSWDBProxy >> _setPersistent [

	flags := flags maskSet: IsPersistentMask
]

{ #category : #accessing }
SSWDBProxy >> _setProxiedObject: anObject [

	"Set proxiedObject ONLY - no other actions.
	Subclasses should NEVER override"
	
	proxiedObject := anObject
]

{ #category : #'actions-internal' }
SSWDBProxy >> _setSwapped [

	"Set the receiver to mark that all references are now pointing to the proxied object.
	For speed this is inlined in _swap"

	flags := flags maskSet: IsSwappedMask
]

{ #category : #'actions-internal' }
SSWDBProxy >> _setUnswapped [

	"Set the receiver to mark that all references are pointing to the receiver rather than the proxied object.
	For speed this is inlined in _unswap"

	flags := flags maskClear: IsSwappedMask
]

{ #category : #'actions-internal' }
SSWDBProxy >> _swap [

	| newFlags |

	newFlags := flags bitOr: IsSwappedMask.
	newFlags == flags ifTrue: [self error: 'attempt to swap already-swapped proxy'].
	flags := newFlags.

	^self _swapReferences
]

{ #category : #'actions-internal' }
SSWDBProxy >> _swapReferences [

	"Private - this method should only be sent from _swap or _unswap.
	Swap references to the receiver with references to the proxiedObject, returning the receiver.
	Subclasses should not override this method, but instead use _postSwapReferences"

	| me him |

	"Cannot swap references if no proxy"
	proxiedObject == nil ifTrue: [^self].

	"Set up 'me' and 'him' so that they will be correct after the swap"
	me := proxiedObject.
	him := self.

	proxiedObject become: self.

	me _setProxiedObject: him.
	me _postSwapReferences.

	^me
]

{ #category : #accessing }
SSWDBProxy >> _unrecoveredProxyString [

	^'%<an unrecovered <1p>%>' expandMacrosWith: self _proxiedObjectClass
]

{ #category : #'actions-internal' }
SSWDBProxy >> _unstore [

	"Mark the receiver in such a way that it will be deleted from the database on commit"

	self subclassResponsibility
]

{ #category : #'actions-internal' }
SSWDBProxy >> _unswap [

	| newFlags |

	newFlags := flags bitAnd: -2 "IsSwappedMask bitInvert".
	newFlags == flags ifTrue: [self error: 'attempt to unswap proxy which has not been swapped'].
	flags := newFlags.

	^self _swapReferences
]

{ #category : #forwarding }
SSWDBProxy >> class [

	"No need to bother the proxiedObject, except where needed to definitively determine their class"

	^self _dbProxyReStore 
	ifNil: 
		[self class]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[(proxiedObject isNil and: [self _proxiedClassIsDefinitive])
					ifTrue: [self _proxiedObjectClass]
					ifFalse: [self _recoveredProxiedObject class]]
			ifFalse: 
				[self class]]]
]

{ #category : #'actions-api' }
SSWDBProxy >> commit [

	"Commit the receiver and its related objects.
	Return success"

	Notification deprecated. "use store instead"

	^self store
]

{ #category : #'non forwarding' }
SSWDBProxy >> debugPrintString [

	^self _dbProxyReStore 
	ifNil: 
		[self debugPrintString]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
				ifTrue: [self _debugPrintString]
				ifFalse: [self debugPrintString]]]
]

{ #category : #forwarding }
SSWDBProxy >> doesNotUnderstand: aMessage [

	"Patched for issue 120-011"

	"Forward aMessage to the proxiedObject, subject to the transactionMutex"
	
	self _dbProxyReStore ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			["Make sure that some other process has not swapped my references while I was waiting for the mutex."
			self isDBProxy ifTrue: 
				[proxiedObject isNil ifTrue: [self _recoverProxiedObject].
				"Swap references to the receiver and proxiedObject. From hereon, must not reference inst vars directly."
				proxyReStore proxy: self _swap forwarded: aMessage]]].

	^aMessage value: self
]

{ #category : #'non forwarding' }
SSWDBProxy >> halt [

	"Go via the reStore so we use debug mode"

	reStore isNil ifTrue: [super halt] ifFalse: [reStore halt]
]

{ #category : #testing }
SSWDBProxy >> includedIn: aCollection [

	"Reciprocal of Collection>>includes: 
	aCollection may use identity test for inclusion, so don't bother the proxiedObject at this stage"

	^aCollection includes: self
]

{ #category : #forwarding }
SSWDBProxy >> instVarAt: anInteger [

	"Avoiding the ProtoObject implementation, selectively forward the message directly to the proxiedObject.
	If we are in a debugging state and the current call stack originates from the IDE, directly access the inst vars of the receiver"	

	^self _dbProxyReStore 
	ifNil: 
		[self instVarAt: anInteger]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[(reStore isDebugging and: [Processor activeProcess isInIDECallStack])
					ifTrue: [super instVarAt: anInteger]
					ifFalse: [self _recoveredProxiedObject instVarAt: anInteger]]
			ifFalse: 
				[self instVarAt: anInteger]]]
]

{ #category : #testing }
SSWDBProxy >> isDBProxy [

	^true
]

{ #category : #'non forwarding' }
SSWDBProxy >> isInteger [

	"No need to bother the proxiedObject"
	
	^false

]

{ #category : #forwarding }
SSWDBProxy >> isKindOf: aClass [

	"No need to bother the proxiedObject if its class is definitively known"

	^self _dbProxyReStore 
	ifNil: 
		[self isKindOf: aClass]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[(proxiedObject isNil and: [self _proxiedClassIsDefinitive])
					ifTrue: [self _proxiedObjectClass includesBehavior: aClass]
					ifFalse: [self _recoveredProxiedObject isKindOf: aClass]]
			ifFalse: 
				[self isKindOf: aClass]]]
]

{ #category : #'actions-internal' }
SSWDBProxy >> onRollback [

	"Sent immediately after rollback. Normally sent direct to the rolled-back object, not via the proxy. 
	If a proxy receives this message it has been flipped by a previous onRollback, so forward without notification"

	^proxiedObject onRollback
]

{ #category : #'non forwarding' }
SSWDBProxy >> printOn: aStream [

	^aStream nextPutAll: self debugPrintString
]

{ #category : #'non forwarding' }
SSWDBProxy >> printString [

	^self debugPrintString
]

{ #category : #'actions-api' }
SSWDBProxy >> refresh [

	"Refresh the receiver and its related objects to their stored state"

	reStore refresh: self withRelatedComponents
]

{ #category : #'actions-api' }
SSWDBProxy >> rollback [

	"Rollback the receiver and its related objects to their previous state"

	reStore rollback: self withRelatedComponents
]

{ #category : #'actions-api' }
SSWDBProxy >> softRollback [

	"Carry out a 'soft rollback' on the receiver. This does not rollback any changes but makes the receiver effectively an 'untouched' persistent object and thus eligible for automatic/transparent refresh if its database row is encountered.
	Since we are a proxy we are by definition not touched, so nothing to do here"

	
]

{ #category : #'actions-api' }
SSWDBProxy >> store [

	"Store the receiver and its related objects; return success.

	NB: This is also a legacy selector whose meaning was 'store in the active transaction'.
	We have repurposed this to also be a direct 'store now' message, which begins and completes in its own transaction.
	Accomodate both new and legacy behavior by checking if there is currently a transaction in progress"

	^self _dbProxyReStore 
	ifNil: 
		[self store]
	ifNotNil: 
		[ :proxyReStore || wasTransactionInProgress |
		proxyReStore transactionCritical: 
			[self isDBProxy 
			ifTrue: 
				[wasTransactionInProgress := reStore isTransactionInProgress.
				(reStore commit: self withRelatedComponents)
					ifTrue: [true]
					ifFalse: [wasTransactionInProgress ifFalse: [StoreFailure signalWith: proxyReStore]. false]]
			ifFalse: 
				[self store]]]
]

{ #category : #'actions-api' }
SSWDBProxy >> storeIn: aReStore [

	"Store the receiver and its related objects.
	Return success"

	self validateReStore: aReStore.

	^self store
]

{ #category : #'actions-internal' }
SSWDBProxy >> validateReStore: aReStore [

	(reStore notNil and: [reStore ~~ reStore]) ifTrue: [self error: 'Attempt to move object between ReStores - Invalid']
]

{ #category : #accessing }
SSWDBProxy >> withComponents [

	"Avoid faulting in the proxied object"

	^SSWDBObjectWithComponents on: self
]

{ #category : #accessing }
SSWDBProxy >> withRelatedComponents [

	"Avoid faulting in the proxied object"

	^SSWDBObjectWithRelatedComponents on: self
]

{ #category : #'non forwarding' }
SSWDBProxy >> yourself [

	"No need to bother the proxiedObject"
	
	^self
]
