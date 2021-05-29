"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBOwnedCollectionSpec,
	#superclass : #SSWDBCollectionSpec,
	#instVars : [
		'targetClass',
		'ownerField',
		'ownerAccessor',
		'orderingSpecs'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> allElementsIn: aCollection [

	^aCollection
]

{ #category : #initializing }
SSWDBOwnedCollectionSpec >> copyCollection: aCollection [

	^aCollection copy
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> dbInstancesFor: aCollectionProxy [

	"Return a DBInstancesCollection representing the instances owned by aCollectionProxy
	and specified by the receiver"

	| instances |

	self ownerField == nil ifTrue: [self setOwnerFieldFrom: aCollectionProxy _reStore].

	instances := aCollectionProxy _reStore instancesOf: self targetClass.

	instances parser qualifyingConditions: (instances parser qualifyingConditions sqlAnd:
		(SSWSQLCondition field: self ownerField equalTo: aCollectionProxy _ownerID)).

	^instances
		
]

{ #category : #'accessing-queries' }
SSWDBOwnedCollectionSpec >> deleteQuery [

	self ownerField == nil ifTrue: [self setOwnerFieldFrom: self reStore].

	^SSWSQLDeleteQuery new
		table: self targetTable;
		conditions: (SSWSQLCondition field: self ownerField equalTo: SSWSQLQueryParameter);
		yourself
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> elementsIn: aCollection notIn: anotherCollection [

	^aCollection reject: [ :each | anotherCollection identityIncludes: each]
]

{ #category : #testing }
SSWDBOwnedCollectionSpec >> hasCollection: updatedCollection anyAdditionsOrRemovalsFrom: originalCollection [

	^updatedCollection size ~= originalCollection size or: [updatedCollection anySatisfy: [ :each | (originalCollection identityIncludes: each) not]]
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> orderingSpecs [

	orderingSpecs isNil ifTrue: [self setOrderingSpecs].

	^orderingSpecs
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> orderingSpecs: anOrderedCollection [

	orderingSpecs := anOrderedCollection
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> owner: aSymbol [

	self ownerAccessor: (SSWInstVarAccessor toAccess: aSymbol in: self targetClass)
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> ownerAccessor [

	"ownerAccessor stores an Accessor configured to access instance variable 
	of the targetClass that holds the reference to the owner object"
	
	^ownerAccessor
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> ownerAccessor: anInstVarAccessor [

	"ownerAccessor stores an Accessor configured to access instance variable 
	of the targetClass that holds the reference to the owner object"
	
	ownerAccessor := anInstVarAccessor
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> ownerClass [

	"Return the class of object that owns the collection specified by the receiver"
	
	^self table instanceClass
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> ownerField [

	"ownerField stores the SSWDBField from the dbTable of the targetClass
	which refers to the the 'owner' object to which the many objects belong.
	
	This is initialized the first time it is required by setOwnerFieldFrom:"
	
	^ownerField
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> ownerField: anSSWDBField [

	"ownerField stores the SSWDBField from the dbTable of the targetClass
	which refers to the the 'owner' object to which the many objects belong.
	
	This is initialized the first time it is required by setOwnerFieldFrom:"
	
	ownerField := anSSWDBField
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> queryClass [

	"Return the correct query class to use for the receiver"
	
	^self templateCollection isOrdered
		ifTrue: [SSWSQLOrderedSelectQuery]
		ifFalse: [SSWSQLSelectQuery]
]

{ #category : #actions }
SSWDBOwnedCollectionSpec >> readAllFor: aCollection [

	"Using a single query (ideally, multiple batched queries if aCollection is too large), read all untouched collections specified by the receiver for members of aCollection"

	| untouched ids stream allResults collections|

	untouched := aCollection select: [ :each | (self accessor valueIn: each) isDBProxy].
	untouched isEmpty ifTrue: [^self].

	ids := untouched collect: [ :each | each _idIn: self reStore].
	stream := ReadStream on: ids.

	allResults := OrderedCollection new: untouched size.
	[stream atEnd] whileFalse: 
		[self readAllStatement readValuesFrom: stream.
		self reStore fetchObjectsOfClass: self targetClass withStatement: self readAllStatement into: allResults].

	collections := Dictionary new: untouched size.
	allResults do: [ :each | (collections at: (self ownerAccessor valueIn: each) _id ifAbsentPut: [self newCollection]) _dbAdd: each].

	(aCollection reject: [ :each | (self accessor valueIn: each) _isRecovered]) do: 
		[ :proxy | 
		(collections at: proxy _id ifAbsent: [self newCollection]) _proxifyIn: (self accessor valueIn: proxy)]
]

{ #category : #'accessing-queries' }
SSWDBOwnedCollectionSpec >> readAllQuery [

	| params |

	params := self newReadAllParameters.
	params atAllPut: SSWSQLQueryParameter.

	^self readQuery
		conditions: (SSWSQLCondition field: self ownerField is: (SSWSQLOperator messageSelector: #includedIn:) to: params);
		yourself
]

{ #category : #'accessing-queries' }
SSWDBOwnedCollectionSpec >> readQuery [

	^self selectQueryIn: self reStore
]

{ #category : #actions }
SSWDBOwnedCollectionSpec >> recoverCollectionForProxy: aCollectionProxy [

	"Return the recovered member objects"

	| statement collection |

	collection := self newCollection.
	statement := self readStatement.
	statement values: (Array with: aCollectionProxy _ownerID).
	self reStore fetchObjectsOfClass: self targetClass withStatement: statement into: collection.
	
	^collection _proxifyIn: aCollectionProxy
]

{ #category : #actions }
SSWDBOwnedCollectionSpec >> refreshCollectionForProxy: aCollectionProxy [

	"Refresh as opposed to read - just fetch the IDs. 
	Return the refreshed contents, i.e. none"

	| reStore statement collection idField |

	reStore := self reStore.
	self ownerField isNil ifTrue: [self setOwnerFieldFrom: reStore].
	idField := (reStore tableForClass: self targetClass) idField.

	collection := self newCollection.
	statement := self refreshStatement.
	statement values: (Array with: aCollectionProxy _ownerID).
	reStore rowsFromStatement: statement do:
		[ :row |
		collection _dbAdd: (reStore deferredObjectOfClass: self targetClass withID: (row lookupField: idField))].
	
	collection _proxifyIn: aCollectionProxy.

	"Since we haven't refreshed any contents return an empty collection"
	^#()
]

{ #category : #actions }
SSWDBOwnedCollectionSpec >> refreshCollectionWithContentsIfUpdatedForProxy: aCollectionProxy [

	"Refresh the receiver collection and its contents if they have been updated
	Return the refreshed contents, i.e. the collection itself"

	| reStore versionField statement collection idField |

	reStore := self reStore.

	"Without versioning we revert to a standard withContents refresh"
	reStore supportsVersioning ifFalse: [^self refreshCollectionWithContentsForProxy: aCollectionProxy].

	idField := (reStore tableForClass: self targetClass) idField.
	versionField := self targetTable versionControlField.
	collection := self newCollection.

	statement := self refreshWithContentsIfUpdatedStatement. 
	statement values: (Array with: aCollectionProxy _ownerID).
	reStore rowsFromStatement: statement do: [ :row | collection _dbAdd: (reStore deferredObjectOfClass: self targetClass withID: (row lookupField: idField) version: (row lookupField: versionField))].

	^collection _proxifyIn: aCollectionProxy
]

{ #category : #'accessing-queries' }
SSWDBOwnedCollectionSpec >> refreshQuery [

	^self readQuery
		fields: (SSWSQLFieldCollection with: self targetTable idField);
		yourself
]

{ #category : #'accessing-queries' }
SSWDBOwnedCollectionSpec >> refreshWithContentsIfUpdatedQuery [

	| query |

	query := self refreshQuery.
	query fields add: self targetTable versionControlField.
	^query

]

{ #category : #'accessing-queries' }
SSWDBOwnedCollectionSpec >> selectQueryIn: anSSWReStore [

	"Private - Patched for issue 120-007"

	| targetTable query |

	self ownerField == nil ifTrue: [self setOwnerFieldFrom: anSSWReStore].
	targetTable := self targetTable.

	query := self queryClass new.

	query
		table: targetTable;
		conditions: (SSWSQLCondition field: self ownerField equalTo: SSWSQLQueryParameter).

	self orderingSpecs do: 
		[ :spec || field |
		spec criteria isSymbol
			ifTrue: [field := targetTable fieldAccessing: spec criteria]
			ifFalse: [field := spec criteria].
		spec isAscending
			ifTrue: [query orderAscendingBy: field]
			ifFalse: [query orderDescendingBy: field]].

	^query
]

{ #category : #initializing }
SSWDBOwnedCollectionSpec >> setOrderingSpecs [

	self templateCollection isSortedCollection
	ifTrue: 
		[self orderingSpecs: (self templateCollection orderingSpecsFor: self targetClass in: self reStore)]
	ifFalse: 
		[self templateCollection isOrdered
			ifTrue: [self orderingSpecs: (Array with: (SSWDBOrderingSpec ascending: self targetTable idField))]
			ifFalse: [self orderingSpecs: #()]]
]

{ #category : #initializing }
SSWDBOwnedCollectionSpec >> setOwnerFieldFrom: anSSWReStore [

	| targetTable |
	
	targetTable := anSSWReStore tableForClass: self targetClass.
	
	self ownerField: (targetTable dataFields detect: [ :field | field accessor = self ownerAccessor])
]

{ #category : #initializing }
SSWDBOwnedCollectionSpec >> setTargetClass: aClass [

	"Double-despatch to the argument"
	
	aClass beTargetClassOf: self
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> targetClass [

	"targetClass stores the Class of object held in the collection specified by the receiver.
	Instances of this class must hold a reference to their owner object"
	
	^targetClass
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> targetClass: aClass [

	"targetClass stores the Class of object held in the collection specified by the receiver.
	Instances of this class must hold a reference to their owner object"
	
	targetClass := aClass
]

{ #category : #accessing }
SSWDBOwnedCollectionSpec >> targetTable [ 

	^self reStore tableForClass: self targetClass
]
