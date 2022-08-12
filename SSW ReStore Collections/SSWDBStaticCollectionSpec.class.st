"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBStaticCollectionSpec,
	#superclass : #SSWDBGeneralCollectionSpec,
	#instVars : [
		'targetClass',
		'deleteEntriesStatement'
	],
	#classVars : [
		'NilCookie'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #initializing }
SSWDBStaticCollectionSpec class >> initialize [

	NilCookie := Object new
]

{ #category : #initializing }
SSWDBStaticCollectionSpec >> createCollectionTable [

	"Intercept to set the Class of the source and target fields in the collection table"
		
	super createCollectionTable.

	self sourceField targetClass: self table instanceClass reStoreIDClass.
	self targetField targetClass: self targetClass
]

{ #category : #'actions-internal' }
SSWDBStaticCollectionSpec >> createNonProxiedInstanceFromRow: aDBRow [

	^(self collectionTable createNonProxiedInstanceFromRow: aDBRow)
		table: self collectionTable;
		yourself
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> dbInstancesFor: aCollectionProxy [

	"Return a DBInstancesCollection representing the instances owned by aCollectionProxy
	and specified by the receiver"

	| instances targetTable |

	instances := aCollectionProxy _reStore instancesOf: self targetClass.
	targetTable := aCollectionProxy _reStore tableForClass: self targetClass.

	instances parser qualifyingTables 
		add: targetTable;
		add: self collectionTable joinedWith: (SSWSQLCondition field: self targetField equalTo: targetTable idField).

	instances parser qualifyingConditions: 
		(instances parser qualifyingConditions sqlAnd:
			(SSWSQLCondition field: self sourceField equalTo: aCollectionProxy _ownerID)).

	^instances
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> deleteEntriesQuery [

	^SSWSQLDeleteQuery new
		table: self collectionTable;
		conditions: (SSWSQLCondition field: self sourceField equalTo: SSWSQLQueryParameter);
		yourself
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> deleteEntriesStatement [

	"Return a prepared statement for deleting the entry table entries for this collection"

	^deleteEntriesStatement ifNil: [deleteEntriesStatement := self reStore prepareStatementForQuery: self deleteEntriesQuery]
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> deleteQuery [

	^self sqlDialect supportsDeleteWithJoin
		ifTrue: [self deleteQueryWithJoin]
		ifFalse: [self deleteQueryWithSubQuery]
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> deleteQueryWithJoin [

	| query |

	query := SSWSQLDeleteQuery new.
	query 
		table: self collectionTable;
		conditions: (SSWSQLCondition field: self sourceField equalTo: SSWSQLQueryParameter).

	self isValueDependent ifTrue: [query addTable: self targetTable withAllFields joinedWithField: self targetField].

	^query
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> deleteQueryWithSubQuery [

	| subquery |

	subquery := SSWSQLSelectQuery new.
	subquery
		field: self targetField;
		table: self collectionTable;
		conditions: (SSWSQLCondition field: self sourceField equalTo: SSWSQLQueryParameter).

	^SSWSQLDeleteQuery new
		table: self targetTable;
		conditions: (SSWSQLCondition field: self targetTable idField is: (SSWSQLOperator messageSelector: #includedIn:) to: subquery asSubQuery);
		yourself
]

{ #category : #'change detection' }
SSWDBStaticCollectionSpec >> equalityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via equality (=)"

	| changes previous |

	changes := OrderedCollection new.
	previous := aCollectionOfEntries collect: [ :entry | entry target].

	aCollection do: [ :each | (previous includes: each) ifFalse: [changes add: (SSWDBCollectionAddition added: each)]].
	aCollectionOfEntries do: [ :entry | (aCollection includes: entry target) ifFalse: [changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	^changes
]

{ #category : #testing }
SSWDBStaticCollectionSpec >> hasMutableTargetInstances [

	^self targetClass isDirectlyPersisted and: [self targetClass isPersistentBaseClass not and: [self targetClass hasMutablePersistentInstances]]
]

{ #category : #'change detection' }
SSWDBStaticCollectionSpec >> identityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via identity (==)"

	| changes previous |

	changes := OrderedCollection new.
	previous := aCollectionOfEntries collect: [ :entry | entry target].

	aCollection do: [ :each | (previous identityIncludes: each) ifFalse: [changes add: (SSWDBCollectionAddition added: each)]].
	aCollectionOfEntries do: [ :entry | (aCollection identityIncludes: entry target) ifFalse: [changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	^changes
]

{ #category : #'actions-internal' }
SSWDBStaticCollectionSpec >> preserveCollectionEntries: aCollection [

	"Private - If the collection stored mutatable directly-persisted objects then we must use a shallowCopy of these for change detection"

	self hasMutableTargetInstances ifTrue: [aCollection do: [ :each | each target: each target shallowCopy]]
]

{ #category : #actions }
SSWDBStaticCollectionSpec >> readAllEntriesFor: ids [

	| stream targetTable allEntries |

	stream := ReadStream on: ids.
	targetTable := self targetTable.
	allEntries := OrderedCollection new: ids size.

	[stream atEnd] whileFalse: 
		[self readAllStatement readValuesFrom: stream.
		self reStore rowsFromStatement: self readAllStatement do: 
			[ :row || entry |
			entry := allEntries add: (self createNonProxiedInstanceFromRow: row).
			entry target isDBProxy ifTrue: 
				["Untouched and possibly unrecovered proxy - use the row data appropriately"
				entry target _isRecovered
					ifTrue: [entry target _refreshFromRow: row table: targetTable]
					ifFalse: [targetTable recoverInstanceFromRow: row into: entry target]]]].

	^allEntries
]

{ #category : #actions }
SSWDBStaticCollectionSpec >> readAllFor: aCollection [

	"Using a single query (ideally, multiple batched queries if aCollection is too large), read all unrecovered collections specified by the receiver for members of aCollection"

	| untouched ids collections |

	untouched := aCollection select: [ :each | (self accessor valueIn: each) isDBProxy].
	untouched isEmpty ifTrue: [^self].

	ids := untouched collect: [ :each | each _idIn: self reStore].
	collections := Dictionary new: untouched size.

	(self readAllEntriesFor: ids) do: [ :each | (collections at: each sourceID ifAbsentPut: [self newCollection]) _dbAdd: each].

	(aCollection reject: [ :each | (self accessor valueIn: each) _isRecovered]) do: 
		[ :proxy || entries |
		entries := collections at: proxy _id ifAbsent: [self newCollection].
		(self accessor valueIn: proxy) 
			_proxiedObject: (entries collect: [ :each | each target]);
			_collectionEntries: entries]
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> readAllQuery [

	| params |

	params := self newReadAllParameters.
	params atAllPut: SSWSQLQueryParameter.

	^self readQuery
		conditions: (SSWSQLCondition field: self sourceField is: (SSWSQLOperator messageSelector: #includedIn:) to: params);
		yourself
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> readQuery [

	| query |

	query := self refreshQuery.
	self targetClass isDirectlyPersisted ifFalse: [query addTable: self targetTable withAllFields joinedWithField: self targetField].

	^query
]

{ #category : #'actions-internal' }
SSWDBStaticCollectionSpec >> recoverBaseClassCollectionForProxy: aCollectionProxy [

	"Private - Recover a collection of base class (String, Date, Number...) objects.
	Return the recovered non-base class objects, i.e. none"

	| statement collection entries |

	statement := self readStatement.
	collection := self newCollection.
	entries := OrderedCollection new.

	statement values: (Array with: aCollectionProxy _ownerID).
	self reStore rowsFromStatement: statement do:
		[ :row |
		(self createNonProxiedInstanceFromRow: row)
			addTo: entries;
			addTargetTo: collection].
	
	aCollectionProxy
		_proxiedObject: collection;
		_collectionEntries: entries.

	^#()
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> recoverCollectionForProxy: aCollectionProxy [

	"Return the recovered member objects"

	^self targetClass isDirectlyPersisted
		ifTrue: [self recoverBaseClassCollectionForProxy: aCollectionProxy]
		ifFalse: [self recoverModelClassCollectionForProxy: aCollectionProxy]
]

{ #category : #'actions-internal' }
SSWDBStaticCollectionSpec >> recoverModelClassCollectionForProxy: aCollectionProxy [

	"Recover a collection of model class (non-base, specifying a table) instances.
	Return the recovered collection"

	| targetTable statement collection entries |

	targetTable := self targetTable.
	statement := self readStatement.
	collection := self newCollection.
	entries := OrderedCollection new.

	statement values: (Array with: aCollectionProxy _ownerID).
	self reStore rowsFromStatement: statement do:
		[ :row || entry |
		entry := self createNonProxiedInstanceFromRow: row.
		entry target isDBProxy ifTrue: 
			["Untouched and possibly unrecovered proxy - use the row data appropriately"
			entry target _isRecovered 
				ifTrue: [entry target _refreshFromRow: row table: targetTable]
				ifFalse: [targetTable recoverInstanceFromRow: row into: entry target]].
		entry
			addTo: entries;
			addTargetTo: collection].
	
	aCollectionProxy
		_proxiedObject: collection;
		_collectionEntries: entries.

	^collection
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> refreshCollectionForProxy: aCollectionProxy [

	"Refresh as opposed to read - just fetch the IDs.
	Return the refreshed contents (always none)"

	^self targetClass isDirectlyPersisted
		ifTrue: [self recoverBaseClassCollectionForProxy: aCollectionProxy]
		ifFalse: [self refreshModelClassCollectionForProxy: aCollectionProxy]
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> refreshCollectionWithContentsIfUpdatedForProxy: aCollectionProxy [

	"Refresh the receiver collection and its contents if they have been updated
	Return the refreshed contents, i.e. the collection itself"

	^self targetClass isDirectlyPersisted
		ifTrue: [self recoverBaseClassCollectionForProxy: aCollectionProxy]
		ifFalse: [self refreshModelClassCollectionWithContentsIfUpdatedForProxy: aCollectionProxy]
]

{ #category : #'actions-internal' }
SSWDBStaticCollectionSpec >> refreshModelClassCollectionForProxy: aCollectionProxy [

	"Refresh as opposed to read - just fetch the IDs.
	Return the refreshed objects, i.e. none"

	| statement collection entries |

	statement := self refreshStatement.
	collection := self newCollection.
	entries := OrderedCollection new.

	statement values: (Array with: aCollectionProxy _ownerID).
	self reStore rowsFromStatement: statement do:
		[ :row | 
		(self createNonProxiedInstanceFromRow: row)
			addTo: entries;
			addTargetTo: collection].
	
	aCollectionProxy
		_proxiedObject: collection;
		_collectionEntries: entries.

	^#()
]

{ #category : #'actions-internal' }
SSWDBStaticCollectionSpec >> refreshModelClassCollectionWithContentsIfUpdatedForProxy: aCollectionProxy [

	"Private - Refresh as opposed to read - just fetch the IDs"

	| collection entries versionField statement |

	"Without versioning we revert to a standard withContents refresh"
	self reStore supportsVersioning ifFalse: [^self refreshCollectionWithContentsForProxy: aCollectionProxy].

	collection := self newCollection.
	entries := OrderedCollection new.
	versionField := self targetTable versionControlField.

	statement := self refreshWithContentsIfUpdatedStatement.
	statement values: (Array with: aCollectionProxy _ownerID).

	self reStore rowsFromStatement: statement do:
		[ :row || entry |
		entry := self createNonProxiedInstanceFromRow: row.
		(entry target isDBProxy and: [entry target _isRecovered and: [entry target _version < (row lookupField: versionField)]]) ifTrue:
			["Out-of-date target object - forget it"
			entry target _forgetProxiedObject].
		entry
			addTo: entries;
			addTargetTo: collection].
	
	aCollectionProxy
		_proxiedObject: collection;
		_collectionEntries: entries.

	^collection
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> refreshQuery [

	^(self selectQueryIn: self reStore)
		conditions: (SSWSQLCondition field: self sourceField equalTo: SSWSQLQueryParameter);
		yourself
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> refreshWithContentsIfUpdatedQuery [

	| query |

	query := self refreshQuery.
	query addTable: self targetTable withIDAndVersionFields joinedWithField: self targetField.

	^query
]

{ #category : #'accessing-queries' }
SSWDBStaticCollectionSpec >> selectQueryIn: anSSWReStore [

	"Return a Query for recovering a collection represented by the receiver from anSSWReStore"
	
	^self queryClass new
		table: self collectionTable;	
		yourself
]

{ #category : #initializing }
SSWDBStaticCollectionSpec >> setTargetClass: aClass [

	"Double-despatch to the argument"
	
	aClass beTargetClassOf: self
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> targetClass [

	"targetClass stores the single Class of the objects stored in the collection modelled by the receiver.
	This must  be a persistent class"
	
	^targetClass
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> targetClass: aClass [

	"targetClass stores the single Class of the objects stored in the collection modelled by the receiver.
	This must  be a persistent class"
	
	targetClass := aClass
]

{ #category : #accessing }
SSWDBStaticCollectionSpec >> targetTable [ 

	^self reStore tableForClass: self targetClass
]
