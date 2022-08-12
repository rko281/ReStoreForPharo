"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBOwnedCollectionProxy,
	#superclass : #SSWDBCollectionProxy,
	#instVars : [
		'copyCollection'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _acquireCopyCollection [

	copyCollection := collectionSpec copyCollection: proxiedObject
]

{ #category : #testing }
SSWDBOwnedCollectionProxy >> _checkHasChanged [

	^self _isDeleted or: [self _isPersistent not or: [collectionSpec hasCollection: proxiedObject anyAdditionsOrRemovalsFrom: copyCollection]]
]

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _commitChangesPhase1 [

	"The only collection-level change is deletion of the entire collection; this is done in phase 2"
	^true
]

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _commitChangesPhase2 [

	"Deletion of dependent collection elements - done as part of phase 2 to allow moved elements to first have their owner pointer updated"
	(collectionSpec isValueDependent and: [self _isDeleted]) ifTrue: 
		[collectionSpec deleteStatement
			values: (Array with: owner _id);
			exec].

	^true
]

{ #category : #accessing }
SSWDBOwnedCollectionProxy >> _copyCollection [

	"The receiver automatically detects changes to its proxiedObject 
	by maintaining a copy of its previous state. This is held in copyCollection"
	
	^copyCollection
]

{ #category : #accessing }
SSWDBOwnedCollectionProxy >> _copyCollection: aCollection [

	"The receiver automatically detects changes to its proxiedObject 
	by maintaining a copy of its previous state. This is held in copyCollection"
	
	copyCollection := aCollection
]

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _forgetProxiedObject [

	copyCollection := nil.
	super _forgetProxiedObject
]

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _postCommitChanges [

	self 
		_setPersistent;
		_acquireCopyCollection
]

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _prepareToCommitPhase1 [

	"Prepare to 'commit' the receiver by ensuring that all elements added to the	proxiedObject point back to the owner.
	Removals are handled in phase2 to allow elements to be transferred between owned collections"

	| added |

	self _isPersistent
	ifTrue:
		[self _isDeleted
			ifTrue: [added := #()]
			ifFalse: [added := collectionSpec elementsIn: proxiedObject notIn: copyCollection]]
	ifFalse:
		[added := collectionSpec allElementsIn: proxiedObject].

	added := added reject: [ :each | each isNil].

	added isEmpty ifFalse:
		[owner __ensureActive.
		added do: 
			[ :each | 
			each _ensureActiveIn: reStore.
			collectionSpec ownerAccessor value: owner _proxiedObject in: each]].

	"If the receiver is persistent we need phase 2"
	^self _isPersistent
]

{ #category : #'actions-internal' }
SSWDBOwnedCollectionProxy >> _prepareToCommitPhase2 [

	"Prepare to 'commit' the receiver by ensuring that elements removed from the receiver have their backpointer nil'd, or are deleted if dependent"

	| removed potentialOwners |

	self _isDeleted
	ifTrue: 
		[removed := copyCollection.
		potentialOwners := Array with: owner _proxiedObject]
	ifFalse: 
		[removed := collectionSpec elementsIn: copyCollection notIn: proxiedObject.
		potentialOwners := Array with: owner with: owner _proxiedObject].

	removed := removed reject: [ :each | each isNil or: [(collectionSpec ownerAccessor valueIn: each) ifNil: ["manually nil'd out" false] ifNotNil: [ :eachOwner | (potentialOwners identityIncludes: eachOwner) not]]].

	collectionSpec isValueDependent
	ifTrue:
		[self _isDeleted ifTrue: [removed do: [ :each | each isDBProxy ifTrue: [reStore transaction addDeletedObject: each]]].
		removed do: [ :each | each unstore]]
	ifFalse:
		[removed do: 
			[ :each |
			collectionSpec ownerAccessor value: nil in: each.
			each _ensureActiveIn: reStore]]
]

{ #category : #accessing }
SSWDBOwnedCollectionProxy >> _proxiedObject: aCollection [

	"Overriden to set the copyCollection"
	
	super _proxiedObject: aCollection.
	self _acquireCopyCollection
]

{ #category : #accessing }
SSWDBOwnedCollectionProxy >> _unchangedCollection [

	"Answer the receiver's collection prior to any changes. This is used to roll the receiver back to its previous state"

	"Need to return a copy"
	^collectionSpec copyCollection: copyCollection
]
