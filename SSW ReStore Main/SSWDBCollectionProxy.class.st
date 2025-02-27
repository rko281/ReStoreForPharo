"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBCollectionProxy',
	#superclass : 'SSWDBProxy',
	#instVars : [
		'collectionSpec',
		'owner'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'accessing' }
SSWDBCollectionProxy >> _collectionSpec [

	"collectionSpec stores the SSWDBCollectionSpec which, given the receiver's ownerID,
	can query for the members of the collection proxy'd by the receiver"
	
	^collectionSpec
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> _collectionSpec: anSSWDBCollectionSpec [

	"dbCollectionSpec stores the SSWDBCollectionSpec which, given the receiver's ownerID,
	can query for the members of the collection proxy'd by the receiver"
	
	collectionSpec := anSSWDBCollectionSpec
]

{ #category : 'actions-refresh' }
SSWDBCollectionProxy >> _forceRefresh [

	self _isRecovered ifTrue: [collectionSpec refreshCollectionForProxy: self]
]

{ #category : 'actions-refresh' }
SSWDBCollectionProxy >> _forceRefreshWithContents [

	"Return the refreshed elements"

	^self _isRecovered 
		ifTrue: [collectionSpec refreshCollectionWithContentsForProxy: self]
		ifFalse: [#()]
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> _owner [

	"owner stores the proxy of the object to which the collection proxy'd by the receiver belongs.
	Holding this ensures that the owner is not GC'd before the collection.

	NB owner ALWAYS holds the actual proxy, not the owning object itself"
	
	^owner
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> _owner: anObject [

	"owner stores the object to which the collection proxy'd by the receiver belongs.
	Holding this ensures that the owner is not GC'd before the collection.

	NB owner ALWAYS holds the actual proxy, not the owning object itself"
	
	owner := anObject
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> _ownerID [

	"Return the unique ID (Integer) of the object to which the collection proxy'd by the receiver belongs"
	
	^owner _id
]

{ #category : 'actions-internal' }
SSWDBCollectionProxy >> _postSwapReferences [

	"Inform the owner"

	owner _collectionProxySwapped: self
]

{ #category : 'actions-internal' }
SSWDBCollectionProxy >> _prepareToCommit [

	"Default: no action for collections"

	^self
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> _proxiedObjectClass [
	
	^collectionSpec collectionClass
]

{ #category : 'actions-internal' }
SSWDBCollectionProxy >> _recoverProxiedObject [

	collectionSpec recoverCollectionForProxy: self
]

{ #category : 'actions-refresh' }
SSWDBCollectionProxy >> _refreshIfUpdated [

	self _isRecovered ifTrue: [collectionSpec refreshCollectionIfUpdatedForProxy: self]
]

{ #category : 'actions-refresh' }
SSWDBCollectionProxy >> _refreshWithContentsIfUpdated [

	"Return the refreshed elements"

	^self _isRecovered 
		ifTrue: [collectionSpec refreshCollectionWithContentsIfUpdatedForProxy: self]
		ifFalse: [#()]
]

{ #category : 'actions-internal' }
SSWDBCollectionProxy >> _rollbackChanges [

	"Forget any changes by reinstantiating the unchanged collection.
	Also transfer over any events registered against the current proxiedObject"

	| unchangedCollection me changedCollection |

	self _clearDeleted.

	unchangedCollection := self _unchangedCollection.
	unchangedCollection == proxiedObject ifTrue: [^self _unswap].

	me := proxiedObject.
	changedCollection := self.
	self _unswap.

	me _setProxiedObject: unchangedCollection.
	changedCollection getEvents ifNotNil: [ :events | me _proxiedObject setEvents: events]
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> _unchangedCollection [

	"Answer the receiver's collection prior to any changes. This is used to roll the receiver back to its previous state"

	^self subclassResponsibility
]

{ #category : 'actions-internal' }
SSWDBCollectionProxy >> _unstore [

	self _isDeleted ifTrue: [^self].

	self _isPersistent 
		ifTrue: [self _setDeleted]
		ifFalse: [reStore removeFromTransaction: self]
]

{ #category : 'forwarding' }
SSWDBCollectionProxy >> orRemote [

	"Use the proxied collection, if in memory, otherwise the remote collection"

	^proxiedObject == nil
		ifTrue: [self remote]
		ifFalse: [self]


	
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> remote [

	^collectionSpec dbInstancesFor: self
]

{ #category : 'public' }
SSWDBCollectionProxy >> size [

	"Optimisation for collections - go direct.
	ASSERT: the proxiedObject's implementation of size is fast and non-modifying"

	^self _dbProxyReStore 
	ifNil: 
		[self size]
	ifNotNil: 
		[ :proxyReStore |
		proxyReStore transactionCritical: 
			[self isDBProxy 
				ifTrue: [self _recoveredProxiedObject size]
				ifFalse: [self size]]]
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> withComponents [

	"Avoid faulting in the proxied object"

	^SSWDBCollectionWithContents on: self
]

{ #category : 'accessing' }
SSWDBCollectionProxy >> withRelatedComponents [

	"Avoid faulting in the proxied object"

	^SSWDBCollectionWithRelatedContents on: self
]
