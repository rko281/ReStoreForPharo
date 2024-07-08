Extension { #name : 'Collection' }

{ #category : '*SSW ReStore Main' }
Collection >> hasAnyChanged [

	"Return whether any elements of the receiver or their related objects have changed in the image since loading from the ReStore instance in which they reside"

	^self isEmpty not and: [(self anyOne _reStoreIfNone: [self errorNotPersistent]) haveAnyChanged: (self collect: [ :each | each withRelatedComponents])]
]

{ #category : '*SSW ReStore Main' }
Collection >> refreshAll [

	"Refresh the elements of the receiver and their related objects to their stored state in the ReStore in which they reside"

	self isEmpty ifFalse: [(self anyOne _reStoreIfNone: [self errorNotPersistent]) refreshAll: (self collect: [ :each | each withRelatedComponents])]
]

{ #category : '*SSW ReStore Main' }
Collection >> rollbackAll [

	"Rollback the elements of the receiver and their related objects to their previous state in the ReStore in which they reside"

	self isEmpty ifFalse: [(self anyOne _reStoreIfNone: [self errorNotPersistent]) rollbackAll: (self collect: [ :each | each withRelatedComponents])]
]

{ #category : '*SSW ReStore Main' }
Collection >> store [

	"Override to prevent attempt to store a non-persistent collection independently of its owner"

	^self storeIn: (self _reStoreIfNone: [self errorNotPersistent])
]

{ #category : '*SSW ReStore Main' }
Collection >> storeAll [

	"Store the elements of the receiver and their related objects in their ReStore or the default ReStore if not yet persistent, returning success.
	In the event of a failure the default action is to abandon the failed transaction leaving the receiver in its current state. 
	To handle transaction failure manually (e.g. to rollback and refresh) trap ObjectCommitFailure"

	"ASSERT: all elements of the receiver belong to the same ReStore instance (or none, if not yet persistent)"

	^self isEmpty 
		ifTrue: [true]
		ifFalse: [self storeAllIn: (self anyOne _reStoreIfNone: [SSWReStore default])]
]

{ #category : '*SSW ReStore Main' }
Collection >> storeAllIn: aReStore [

	"Private - Store the elements of the receiver and their related objects in aReStore; return success.
	In the event of a failure the default action is to abandon the failed transaction leaving the elements of the receiver in their current state. 
	To handle transaction failure manually (e.g. to rollback and refresh) trap StoreFailure"

	^(aReStore commitAll: (self collect: [:each | each withRelatedComponents]))
		ifTrue: [true]
		ifFalse: [StoreFailure signalWith: aReStore. false]
]

{ #category : '*SSW ReStore Main' }
Collection >> unstoreAll [

	"Unstore (delete) the elements of the receiver in the ReStore in which they reside. 
	Dependent objects will also be unstored"

	^self isEmpty 
		ifTrue: [true]
		ifFalse: [(self anyOne _reStoreIfNone: [self errorNotPersistent]) commitAll: (self collect: [ :each | each unstored])]
]

{ #category : '*SSW ReStore Main' }
Collection >> withComponents [

	^SSWDBCollectionWithContents on: self
]

{ #category : '*SSW ReStore Main' }
Collection >> withRelatedComponents [

	^SSWDBCollectionWithRelatedContents on: self
]
