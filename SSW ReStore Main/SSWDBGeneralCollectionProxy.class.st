"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBGeneralCollectionProxy,
	#superclass : #SSWDBCollectionProxy,
	#instVars : [
		'collectionEntries',
		'changes',
		'isDeleted'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'instance creation' }
SSWDBGeneralCollectionProxy class >> new [

	^super new
		_isDeleted: false;
		yourself
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _changes [

	"During commit, changes temporatily stores a Collection of 	SSWDBCollectionChanges 
	representing changes made to the receiver's proxied collection"

	^changes
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _changes: anOrderedCollection [

	"During commit, changes temporatily stores a Collection of 	SSWDBCollectionChanges 
	representing changes made to the receiver's proxied collection"

	changes := anOrderedCollection
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _checkHasChanged [

	| changed |

	self _isDeleted ifTrue: [^true].

	self _setChanges.
	changed := changes isEmpty not.

	"Clear out the changes"
	self _resetChanges.

	^changed
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _collectionEntries [

	"The receiver automatically detects changes to its proxiedObject collection
	by keeping a copy of the SSWDBCollectionEntry records that define the colleciton in the DB"
	
	^collectionEntries
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _collectionEntries: aCollection [

	"The receiver automatically detects changes to its proxiedObject collection
	by keeping a copy of the SSWDBCollectionEntry records that define the colleciton in the DB"
	
	collectionEntries := aCollection
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _commitChanges [

	changes do: [ :change | change commitFor: self].

	"Deletion of collection table entries, keys and values (as appropriate)"
	self _isDeleted ifTrue: 
		[collectionSpec isValueDependent ifTrue: 
			[collectionSpec deleteStatement
				values: (Array with: owner _id);
				exec].

		"Keys"
		collectionSpec isKeyDependent ifTrue: 
			[collectionSpec deleteKeysStatement ifNotNil: 
				[ :stmt |
				stmt
					values: (Array with: owner _id);
					exec]].

		"Entries, if not already done by the above"
		(collectionSpec sqlDialect supportsDeleteWithJoin and: [collectionSpec isKeyDependent or: [collectionSpec isValueDependent]]) ifFalse: 
			[collectionSpec deleteEntriesStatement
				values: (Array with: owner _id);
				exec]].

	^true
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _hasChanged [

	"Unlike _checkHasChanged, do not clear out the changes
	 - prepareToCommit will use them"
	
	self _setChanges.

	^self _isDeleted or: [changes isEmpty not]
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _isDeleted [

	"The receiver stores its deleted status as a Boolean"

	^isDeleted
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _isDeleted: aBoolean [

	"The receiver stores its deleted status as a Boolean"

	isDeleted := aBoolean
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _isPersistent [

	^collectionEntries ~~ nil or: [self _isRecovered not]
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _postCommitChanges [

	self _isPersistent 
		ifTrue: [changes do: [ :change | change applyTo: collectionEntries]]
		ifFalse: [collectionEntries := changes collect: [ :change | change affectedEntry]].
	
	self _resetChanges
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _prepareToCommit [

	"The receiver is guaranteed to be sent _hasChanged prior to this method,
	so no need to reassemble the changes"
	changes do: [ :change | change prepareToCommitFor: self]
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _resetChanges [

	changes := nil
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _rollbackChanges [

	"Rollback any changes made by reinstantiating from the collectionEntries.
	Also transfer any events associated with the collection"

	| rollbackCollection me |

	self _checkHasChanged
	ifTrue:
		[rollbackCollection := collectionSpec newCollection.
		collectionEntries do: [ :entry | entry addTargetTo: rollbackCollection].
		proxiedObject getEvents ifNotNil: [ :events | rollbackCollection setEvents: events]]
	ifFalse:
		[rollbackCollection := self	"Will be proxiedObject after the swap"].

	me := proxiedObject.
	self _swapReferences.

	me _proxiedObject: rollbackCollection
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _setChanges [

	self _isPersistent
	ifTrue: 
		[self _isDeleted
		ifTrue: 
			[changes := #().
			(collectionSpec isValueDependent or: [collectionSpec isKeyDependent]) ifTrue: 
				[collectionEntries do: 
					[ :each |
					(collectionSpec isKeyDependent and: [each index isDBProxy]) ifTrue: 
						[reStore transaction addDeletedObject: each index _proxiedObject.
						each index unstore].
					(collectionSpec isValueDependent and: [each target isDBProxy]) ifTrue: 
						[reStore transaction addDeletedObject: each target _proxiedObject.
						each target unstore]]]]
		ifFalse: 
			[changes := proxiedObject _changesFrom: collectionEntries]]
	ifFalse: 
		[changes := proxiedObject _collectionAdditions]
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _shouldUnstoreKey: anObject [

	^self _collectionSpec isKeyDependent and: [(self _proxiedObject includesKey: anObject) not]
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _shouldUnstoreValue: anObject [

	^self _collectionSpec isValueDependent and: [(self _proxiedObject identityIncludes: anObject) not]
]

{ #category : #actions }
SSWDBGeneralCollectionProxy >> _unstore [

	self _isPersistent 
		ifTrue: [isDeleted := true]
		ifFalse: [reStore removeFromTransaction: self]
]
