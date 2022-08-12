"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBGeneralCollectionProxy,
	#superclass : #SSWDBCollectionProxy,
	#instVars : [
		'collectionEntries',
		'changes'
	],
	#category : #'SSW ReStore Main'
}

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

	(self _isDeleted or: [self _isPersistent not]) ifTrue: [^true].

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
	
	collectionEntries := aCollection.
	collectionSpec preserveCollectionEntries: aCollection
]

{ #category : #'actions-internal' }
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

{ #category : #'actions-internal' }
SSWDBGeneralCollectionProxy >> _forgetProxiedObject [

	collectionEntries := nil.
	super _forgetProxiedObject
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _hasChanged [

	"Unlike _checkHasChanged, do not clear out the changes - prepareToCommit will use them"
	
	self _setChanges.

	^self _isDeleted or: [self _isPersistent not or: [changes isEmpty not]]
]

{ #category : #'actions-internal' }
SSWDBGeneralCollectionProxy >> _postCommitChanges [

	self _isPersistent 
		ifTrue: [changes do: [ :change | change applyTo: collectionEntries]]
		ifFalse: [self _collectionEntries: (changes collect: [ :change | change affectedEntry])].

	self 
		_setPersistent;
		_resetChanges
]

{ #category : #'actions-internal' }
SSWDBGeneralCollectionProxy >> _prepareToCommit [

	"The receiver is guaranteed to be sent _hasChanged prior to this method,
	so no need to reassemble the changes"
	changes do: [ :change | change prepareToCommitFor: self]
]

{ #category : #'actions-internal' }
SSWDBGeneralCollectionProxy >> _resetChanges [

	changes := nil
]

{ #category : #'actions-internal' }
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
						[reStore transaction addDeletedObject: each index.
						each index unstore].
					(collectionSpec isValueDependent and: [each target isDBProxy]) ifTrue: 
						[reStore transaction addDeletedObject: each target.
						each target unstore]]]]
		ifFalse: 
			[changes := collectionSpec changesTo: proxiedObject from: collectionEntries]]
	ifFalse: 
		[changes := collectionSpec allAdditionsTo: proxiedObject]
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _shouldUnstoreKey: anObject [

	^self _collectionSpec isKeyDependent and: [(self _proxiedObject includesKey: anObject) not]
]

{ #category : #testing }
SSWDBGeneralCollectionProxy >> _shouldUnstoreValue: anObject [

	^self _collectionSpec isValueDependent and: [(self _proxiedObject identityIncludes: anObject) not]
]

{ #category : #accessing }
SSWDBGeneralCollectionProxy >> _unchangedCollection [

	"Answer the receiver's collection prior to any changes. This is used to roll the receiver back to its previous state"

	| unchangedCollection |

	self _checkHasChanged ifFalse: [^proxiedObject].

	unchangedCollection := collectionSpec newCollection.
	collectionEntries notNil ifTrue: [collectionEntries do: [ :entry | entry addTargetTo: unchangedCollection]].
	
	^unchangedCollection
]
