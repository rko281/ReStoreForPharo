"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionProxy,
	#superclass : #SSWDBProxy,
	#instVars : [
		'collectionSpec',
		'owner'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #testing }
SSWDBCollectionProxy >> _checkHasChanged [

	"Default - collection proxies do not keep track of their changes"

	^false
]

{ #category : #accessing }
SSWDBCollectionProxy >> _collectionSpec [

	"collectionSpec stores the SSWDBCollectionSpec which, given the receiver's ownerID,
	can query for the members of the collection proxy'd by the receiver"
	
	^collectionSpec
]

{ #category : #accessing }
SSWDBCollectionProxy >> _collectionSpec: anSSWDBCollectionSpec [

	"dbCollectionSpec stores the SSWDBCollectionSpec which, given the receiver's ownerID,
	can query for the members of the collection proxy'd by the receiver"
	
	collectionSpec := anSSWDBCollectionSpec
]

{ #category : #'actions-internal' }
SSWDBCollectionProxy >> _commitChanges [

	"Default: no action for collections"
	
	^true
]

{ #category : #'actions-refresh' }
SSWDBCollectionProxy >> _forceRefresh [

	self _isRecovered ifTrue: [collectionSpec refreshCollectionForProxy: self]
]

{ #category : #'actions-refresh' }
SSWDBCollectionProxy >> _forceRefreshWithContents [

	"Return the refreshed elements"

	^self _isRecovered 
		ifTrue: [collectionSpec refreshCollectionWithContentsForProxy: self]
		ifFalse: [#()]
]

{ #category : #accessing }
SSWDBCollectionProxy >> _owner [

	"owner stores the proxy of the object to which the collection proxy'd by the receiver belongs.
	Holding this ensures that the owner is not GC'd before the collection.

	NB owner ALWAYS holds the actual proxy, not the owning object itself"
	
	^owner
]

{ #category : #accessing }
SSWDBCollectionProxy >> _owner: anObject [

	"owner stores the object to which the collection proxy'd by the receiver belongs.
	Holding this ensures that the owner is not GC'd before the collection.

	NB owner ALWAYS holds the actual proxy, not the owning object itself"
	
	owner := anObject
]

{ #category : #accessing }
SSWDBCollectionProxy >> _ownerID [

	"Return the unique ID (Integer) of the object to which the collection proxy'd by the receiver belongs"
	
	^owner _id
]

{ #category : #'actions-internal' }
SSWDBCollectionProxy >> _postSwapReferences [

	"Inform the owner"

	owner _collectionProxySwapped: self
]

{ #category : #'actions-internal' }
SSWDBCollectionProxy >> _prepareToCommit [

	"Default: no action for collections"

	^self
]

{ #category : #'actions-internal' }
SSWDBCollectionProxy >> _recoverProxiedObject [

	collectionSpec recoverCollectionForProxy: self
]

{ #category : #'actions-refresh' }
SSWDBCollectionProxy >> _refreshIfUpdated [

	self _isRecovered ifTrue: [collectionSpec refreshCollectionIfUpdatedForProxy: self]
]

{ #category : #'actions-refresh' }
SSWDBCollectionProxy >> _refreshWithContentsIfUpdated [

	"Return the refreshed elements"

	^self _isRecovered 
		ifTrue: [collectionSpec refreshCollectionWithContentsIfUpdatedForProxy: self]
		ifFalse: [#()]
]

{ #category : #accessing }
SSWDBCollectionProxy >> _unrecoveredProxyString [

	^'<an unrecovered ', collectionSpec templateCollection class name, '>'
]

{ #category : #forwarding }
SSWDBCollectionProxy >> class [

	^proxiedObject == nil
		ifTrue: [collectionSpec collectionClass]
		ifFalse: [proxiedObject class]
]

{ #category : #forwarding }
SSWDBCollectionProxy >> orRemote [

	"Use the proxied collection, if in memory, otherwise the remote collection"

	^proxiedObject == nil
		ifTrue: [self remote]
		ifFalse: [self]


	
]

{ #category : #accessing }
SSWDBCollectionProxy >> remote [

	^collectionSpec dbInstancesFor: self
]

{ #category : #accessing }
SSWDBCollectionProxy >> withComponents [

	"Avoid faulting in the proxied object"

	^SSWDBCollectionWithContents on: self
]

{ #category : #accessing }
SSWDBCollectionProxy >> withRelatedComponents [

	"Avoid faulting in the proxied object"

	^SSWDBCollectionWithRelatedContents on: self
]
