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
SSWDBOwnedCollectionProxy >> _prepareToCommit [

	"Prepare to 'commit' the receiver by ensuring that all elements added to the
	proxiedObject point back to the owner, and that removed elements do not"

	| added removed |

	self _isPersistent
	ifTrue:
		[self _isDeleted
		ifTrue:
			[added := #().
			removed := copyCollection]
		ifFalse:
			[added := collectionSpec elementsIn: proxiedObject notIn: copyCollection.
			removed := collectionSpec elementsIn: copyCollection notIn: proxiedObject]]
	ifFalse:
		[added := collectionSpec allElementsIn: proxiedObject.
		removed := #()].

	added := added reject: [ :each | each isNil].
	removed := removed reject: [ :each | each isNil].

	added isEmpty ifFalse:
		[owner __ensureActive.
		added do: 
			[ :each | 
			each _ensureActiveIn: reStore.
			collectionSpec ownerAccessor value: owner _proxiedObject in: each]].

	collectionSpec isValueDependent
	ifTrue:
		[removed do: [ :each | each unstore]]
	ifFalse:
		[removed do: 
			[ :each | 
			collectionSpec ownerAccessor value: nil in: each.
			each isDBProxy ifTrue: [each _referenced]]]
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
