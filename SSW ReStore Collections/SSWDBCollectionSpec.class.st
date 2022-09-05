"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBCollectionSpec,
	#superclass : #SSWDBTableComponent,
	#instVars : [
		'templateCollection',
		'isValueDependent',
		'isValueRelated',
		'readStatement',
		'refreshStatement',
		'refreshWithContentsIfUpdatedStatement',
		'deleteStatement'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #actions }
SSWDBCollectionSpec >> applyTo: anObject withID: anInteger in: anSSWReStore [

	"'Apply' the one-to-many relationship expressed by this object to the 'one' object anObject.
	This is done by assigning (using the receiver's accessor) a suitable proxy that can
	recover the collection of 'many' objects relating to anObject"
	
	| proxyCollection |
	
	proxyCollection := self collectionProxyClass new.
	proxyCollection
		_reStore: anSSWReStore;
		_collectionSpec: self.
	
	self accessor value: proxyCollection in: anObject
]

{ #category : #defining }
SSWDBCollectionSpec >> beValueDependent [

	isValueDependent := true
]

{ #category : #defining }
SSWDBCollectionSpec >> beValueRelated [

	isValueRelated := true
]

{ #category : #defining }
SSWDBCollectionSpec >> beValueUnrelated [

	isValueRelated := false
]

{ #category : #evaluating }
SSWDBCollectionSpec >> collectionClass [

	^self templateCollection class
]

{ #category : #constants }
SSWDBCollectionSpec >> collectionProxyClass [

	"Return the class of collection proxy to use for collections created by the receiver"
	
	^self subclassResponsibility
]

{ #category : #evaluating }
SSWDBCollectionSpec >> containedTables [

	"By default, no tables are contained"

	^#()
]

{ #category : #evaluating }
SSWDBCollectionSpec >> dbInstancesFor: aCollectionProxy [

	"Return a DBInstancesCollection representing the instances owned by aCollectionProxy
	and specified by the receiver"

	^self subclassResponsibility
]

{ #category : #defining }
SSWDBCollectionSpec >> defineAs: aSymbol in: anSSWDBTable [

	"The receiver has been specified as the kind of object held in inst var named aSymbol
	for the class whose DB table is anSSWDBTable.

	Add the receiver to anSSWDBTable returning the object created"

	^anSSWDBTable define: aSymbol asCollectionSpec: self

]

{ #category : #'accessing-queries' }
SSWDBCollectionSpec >> deleteQuery [

	"Return a SQL query for deleting the elements of this collection"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionSpec >> deleteStatement [

	"Return a prepared statement for deleting this collection"

	^deleteStatement ifNil: [deleteStatement := self reStore prepareStatementForQuery: self deleteQuery]
]

{ #category : #'initialize/release' }
SSWDBCollectionSpec >> freePreparedStatements [

	super freePreparedStatements.

	readStatement notNil ifTrue: [readStatement free].
	refreshStatement notNil ifTrue: [refreshStatement free].
	refreshWithContentsIfUpdatedStatement notNil ifTrue: [refreshWithContentsIfUpdatedStatement free].

	readStatement := nil.
	refreshStatement := nil.
	refreshWithContentsIfUpdatedStatement := nil
]

{ #category : #'initialize/release' }
SSWDBCollectionSpec >> initialize [

	super initialize.

	isValueDependent := false.
	isValueRelated := false
]

{ #category : #testing }
SSWDBCollectionSpec >> isKeyDependent [

	"isKeyDependent indicates whether the key objects of the specified collection are dependent on the existence of the owner of that collection for their own existence.
	False by default since not all collections support keys; subclasses may override.

	c.f. isValueDependent (key and value terminology taken from keysAndValuesDo:)"

	^false
]

{ #category : #testing }
SSWDBCollectionSpec >> isKeyRelated [

	"isKeyRelated indicates whether the key elements of the collection represented by the receiver are related to the owning/source object.
	False by default since not all collections support keys; subclasses may override.

	c.f. isValueDependent (key and value terminology taken from keysAndValuesDo:)"

	^false
]

{ #category : #testing }
SSWDBCollectionSpec >> isRelated [

	^self isValueRelated or: [self isKeyRelated]
]

{ #category : #testing }
SSWDBCollectionSpec >> isValueDependent [

	"isValueDependent indicates whether the value objects of the specified collection are dependent on the existence of the owner of that collection for their own existence.
	c.f. isKeyDependent (key and value terminology taken from keysAndValuesDo:)"

	^isValueDependent
]

{ #category : #testing }
SSWDBCollectionSpec >> isValueRelated [

	"isValueRelated indicates whether elements of the collection represented by the receiver are related to the owning/source object, such that they will be commited/rolled-back with that object when withRelatedComponents is used.
	c.f. isKeyRelated (key and value terminology taken from keysAndValuesDo:)"

	^isValueRelated
]

{ #category : #evaluating }
SSWDBCollectionSpec >> newCollection [

	^self templateCollection copy
]

{ #category : #evaluating }
SSWDBCollectionSpec >> newProxydCollectionFor: aProxyObject [

	^self collectionProxyClass new
		_reStore: aProxyObject _reStore;
		_owner: aProxyObject;
		_collectionSpec: self;
		_setNewNonPersistent;
		yourself
]

{ #category : #'accessing-queries' }
SSWDBCollectionSpec >> readQuery [

	"Return a SQL query for reading this collection"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionSpec >> readStatement [

	"Return a prepared statement for reading this collection"

	^readStatement ifNil: [readStatement := self reStore prepareStatementForQuery: self readQuery]
]

{ #category : #actions }
SSWDBCollectionSpec >> recoverCollectionForProxy: aCollectionProxy [

	"Recover and return the collection defined by the receiver 
	that is wrappered by the given collection proxy"

	^self subclassResponsibility
]

{ #category : #actions }
SSWDBCollectionSpec >> refreshCollectionForProxy: aCollectionProxy [

	"Refresh as opposed to read - just fetch the IDs. 
	Return the refreshed contents, i.e. none"

	^self subclassResponsibility
]

{ #category : #actions }
SSWDBCollectionSpec >> refreshCollectionIfUpdatedForProxy: aCollectionProxy [

	"No versioning on collections themselves, so revert to a standard refresh"

	^self refreshCollectionForProxy: aCollectionProxy
]

{ #category : #actions }
SSWDBCollectionSpec >> refreshCollectionWithContentsForProxy: aCollectionProxy [

	"Refresh the receiver collection and its contents. Essentially, the same as recovering the collection.
	Return the refreshed contents, i.e. the collection itself"

	^self recoverCollectionForProxy: aCollectionProxy
]

{ #category : #actions }
SSWDBCollectionSpec >> refreshCollectionWithContentsIfUpdatedForProxy: aCollectionProxy [

	"Refresh the receiver collection and its contents if they have been updated
	Return the refreshed contents, i.e. the collection itself"

	^self subclassResponsibility
]

{ #category : #'accessing-queries' }
SSWDBCollectionSpec >> refreshQuery [

	"Return a SQL query for refreshing this collection"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionSpec >> refreshStatement [

	"Return a prepared statement for refreshing this collection"

	^refreshStatement ifNil: [refreshStatement := self reStore prepareStatementForQuery: self refreshQuery]
]

{ #category : #'accessing-queries' }
SSWDBCollectionSpec >> refreshWithContentsIfUpdatedQuery [

	"Return a SQL query for refreshing this collection together with its updated contents"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionSpec >> refreshWithContentsIfUpdatedStatement [

	"Return a prepared statement for refreshing this collection together with its updated contents"

	^refreshWithContentsIfUpdatedStatement ifNil: [refreshWithContentsIfUpdatedStatement := self reStore prepareStatementForQuery: self refreshWithContentsIfUpdatedQuery]
]

{ #category : #evaluating }
SSWDBCollectionSpec >> relatedComponentsOf: anObject do: aBlock [

	"We consider a collection always related to the source object since, in ReStore, a collection cannot exist without the source object.
	NB - we are referring to the collection itself, not its elements - these may or may not be related, see isValueRelated / isKeyRelated"

	self componentsOf: anObject do: aBlock
]

{ #category : #accessing }
SSWDBCollectionSpec >> targetClass [

	"The homogeous (super)class of elements of the receiver"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionSpec >> templateCollection [

	"collection stores an empty collection that is used as the template 
	for collections created by this class (i.e. a copy of templateCollection is used)"
	
	^templateCollection
]

{ #category : #accessing }
SSWDBCollectionSpec >> templateCollection: aCollection [

	"collection stores an empty collection that is used as the template 
	for collections created by this class (i.e. a copy of templateCollection is used)"
	
	templateCollection := aCollection
]
