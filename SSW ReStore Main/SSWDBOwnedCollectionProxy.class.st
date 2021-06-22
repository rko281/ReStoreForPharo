"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBOwnedCollectionProxy,
	#superclass : #SSWDBCollectionProxy,
	#instVars : [
		'copyCollection'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #actions }
SSWDBOwnedCollectionProxy >> _acquireCopyCollection [

	copyCollection := collectionSpec copyCollection: proxiedObject
]

{ #category : #testing }
SSWDBOwnedCollectionProxy >> _checkHasChanged [

	^self _isDeleted or: [self _isPersistent not or: [collectionSpec hasCollection: proxiedObject anyAdditionsOrRemovalsFrom: copyCollection]]
]

{ #category : #actions }
SSWDBOwnedCollectionProxy >> _commitChangesPhase1 [

	"The only collection-level change is deletion of the entire collection; this is done in phase 2"
	^true
]

{ #category : #actions }
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

{ #category : #testing }
SSWDBOwnedCollectionProxy >> _isDeleted [

	^proxiedObject == nil and: [copyCollection ~~ nil]
]

{ #category : #testing }
SSWDBOwnedCollectionProxy >> _isPersistent [

	^copyCollection ~~ nil or: [self _isRecovered not]
]

{ #category : #actions }
SSWDBOwnedCollectionProxy >> _postCommitChanges [

	self _acquireCopyCollection
]

{ #category : #actions }
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

{ #category : #actions }
SSWDBOwnedCollectionProxy >> _prepareToCommitPhase2 [

	"Prepare to 'commit' the receiver by ensuring that elements removed from the receiver have their backpointer nil'd, or are deleted if dependent"

	| removed ownerObject |

	self _isDeleted
	ifTrue: 
		[removed := copyCollection.
		ownerObject := owner _copyObject]
	ifFalse: 
		[removed := collectionSpec elementsIn: copyCollection notIn: proxiedObject.
		ownerObject := owner _proxiedObject].

	removed := removed reject: [ :each | each isNil or: [(collectionSpec ownerAccessor valueIn: each) ifNil: ["manually nil'd out" false] ifNotNil: [ :eachOwner | eachOwner ~~ ownerObject]]].

	collectionSpec isValueDependent
	ifTrue:
		[self _isDeleted ifTrue: [removed do: [ :each | each isDBProxy ifTrue: [reStore transaction addDeletedObject: each _proxiedObject]]].
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

{ #category : #actions }
SSWDBOwnedCollectionProxy >> _rollbackChanges [

	"Forget any changes by instantiating from the copyCollection.
	Also transfer over any events registered against the current proxiedObject"

	| wasDeleted me him spec |

	"Reinstate the proxiedObject if the receiver was deleted"
	self _isDeleted 
	ifTrue: 
		[proxiedObject := copyCollection.
		copyCollection := proxiedObject copy.
		wasDeleted := true]
	ifFalse:
		[wasDeleted := false].

	me := proxiedObject.
	him := self.
	spec := collectionSpec.
	self _swapReferences.

	wasDeleted ifFalse:
		[me _proxiedObject: (spec copyCollection: me _copyCollection).
		him getEvents ifNotNil: [ :events | me _proxiedObject setEvents: events]]
]

{ #category : #actions }
SSWDBOwnedCollectionProxy >> _unstore [

	"Point references to the proxiedObject to the copyCollection
	 - this enables identity to be preserved in the event of a rollback"

	self _isPersistent
		ifTrue: [copyCollection := proxiedObject become: copyCollection]
		ifFalse: [reStore removeFromTransaction: self].

	proxiedObject := nil
]
