"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBStaticDictionarySpec,
	#superclass : #SSWDBKeyedStaticCollectionSpec,
	#instVars : [
		'keyClass',
		'isKeyDependent',
		'isKeyRelated',
		'keyTableForRead',
		'keyTableForRefresh',
		'deleteKeysStatement'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #initializing }
SSWDBStaticDictionarySpec >> beKeyDependent [

	isKeyDependent := true
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> beKeyRelated [

	isKeyRelated := true
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> beKeyUnrelated [

	isKeyRelated := false
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> createCollectionTable [

	"Intercept to set the Class of the key field in the collection table"
		
	super createCollectionTable.

	(self collectionTable fieldAccessing: #index) targetClass: self keyClass
]

{ #category : #'accessing-queries' }
SSWDBStaticDictionarySpec >> deleteKeysQuery [

	^self sqlDialect supportsDeleteWithJoin
	ifTrue: 
		[self isValueDependent 
			ifTrue: [nil] "Will be handled by deleteStatement"
			ifFalse: [self deleteQueryWithJoin]]
	ifFalse: 
		[self deleteKeysQueryWithSubQuery]
]

{ #category : #'accessing-queries' }
SSWDBStaticDictionarySpec >> deleteKeysQueryWithSubQuery [

	| subquery |

	subquery := SSWSQLSelectQuery new.
	subquery
		field: self indexField;
		table: self collectionTable;
		conditions: (SSWSQLCondition field: self sourceField equalTo: SSWSQLQueryParameter).

	^SSWSQLDeleteQuery new
		table: self keyTable;
		conditions: (SSWSQLCondition field: self keyTable idField is: (SSWSQLOperator messageSelector: #includedIn:) to: subquery asSubQuery);
		yourself
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> deleteKeysStatement [

	"Return a prepared statement for deleting the keys of this collection"

	^deleteKeysStatement ifNil: [self deleteKeysQuery ifNotNil: [ :query | deleteKeysStatement := self reStore prepareStatementForQuery: query]]
]

{ #category : #'accessing-queries' }
SSWDBStaticDictionarySpec >> deleteQueryWithJoin [

	| query |

	query := super deleteQueryWithJoin.

	self isKeyDependent ifTrue: [query addTable: self keyTable withAllFields joinedWithField: self indexField].

	^query
]

{ #category : #'initialize/release' }
SSWDBStaticDictionarySpec >> initialize [

	super initialize.

	isKeyDependent := false.
	isKeyRelated := false
]

{ #category : #testing }
SSWDBStaticDictionarySpec >> isKeyDependent [

	"Dictionary keys can optionally be dependent (see isValueDependent)"

	^isKeyDependent
]

{ #category : #testing }
SSWDBStaticDictionarySpec >> isKeyRelated [

	"Dictionary keys can optionally be related (see isValueRelated)"

	^isKeyRelated
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyClass [

	"keyClass stores the Class of the objects that are the keys to this Dictionary.
	This should be a valid base class (String, Date etc.) or a persistent class"

	^keyClass
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyClass: aBasicClass [

	"keyClass stores the Class of the objects that are the keys to this Dictionary.
	This should be a valid base class (String, Date etc.) or a persistent class"

	keyClass := aBasicClass
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyTable [ 

	^self reStore tableForClass: self keyClass
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyTableForRead [

	^keyTableForRead
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyTableForRefresh [

	^keyTableForRefresh
]

{ #category : #'actions-internal' }
SSWDBStaticDictionarySpec >> readAllEntriesFor: ids [

	| stream allEntries statement targetTable keyTable |

	stream := ReadStream on: ids.
	allEntries := OrderedCollection new: ids size.

	"Lazy initialization of readAllStatement may be needed before tables are valid"
	statement := self readAllStatement.
	self targetClass isPersistentBaseClass ifFalse: [targetTable := self targetTable].
	self keyClass isPersistentBaseClass ifFalse: [keyTable := self keyTableForRead].
		
	[stream atEnd] whileFalse: 
		[statement readValuesFrom: stream.
		self targetClass isPersistentBaseClass ifFalse: [targetTable := self targetTable].
		self keyClass isPersistentBaseClass ifFalse: [keyTable := self keyTableForRead].
		self reStore rowsFromStatement: self readAllStatement do: 
			[ :row || entry |
			entry := allEntries add: (self createNonProxiedInstanceFromRow: row).
			entry index isDBProxy ifTrue: 
				["Untouched and possibly unrecovered proxy - use the row data appropriately"
				entry index _isRecovered 
					ifTrue: [entry index _refreshFromRow: row table: keyTable]
					ifFalse: [keyTable recoverInstanceFromRow: row into: entry index]].
			entry target isDBProxy ifTrue: 
				["Untouched and possibly unrecovered proxy - use the row data appropriately"
				entry target _isRecovered
					ifTrue: [entry target _refreshFromRow: row table: targetTable]
					ifFalse: [targetTable recoverInstanceFromRow: row into: entry target]]]].

	^allEntries
]

{ #category : #'actions-internal' }
SSWDBStaticDictionarySpec >> readAllFor: aCollection [

	"Using a single query (ideally, multiple batched queries if aCollection is too large), read all unrecovered collections specified by the receiver for members of aCollection"

	| untouched ids collections |

	untouched := aCollection select: [ :each | (self accessor valueIn: each) isDBProxy].
	untouched isEmpty ifTrue: [^self].

	ids := untouched collect: [ :each | each _idIn: self reStore].
	collections := Dictionary new: untouched size.

	(self readAllEntriesFor: ids) do: [ :each | (collections at: each sourceID ifAbsentPut: [OrderedCollection new]) add: each].

	(aCollection reject: [ :each | (self accessor valueIn: each) _isRecovered]) do: 
		[ :proxy || entries dict |
		entries := collections at: proxy _id ifAbsent: [OrderedCollection new].
		dict := self newCollection.
		entries do: [ :each | dict at: each index put: each target].
		(self accessor valueIn: proxy) 
			_proxiedObject: dict;
			_collectionEntries: entries]
]

{ #category : #'accessing-queries' }
SSWDBStaticDictionarySpec >> readQuery [

	| query |

	query := super readQuery.
	self keyClass isPersistentBaseClass ifFalse: [keyTableForRead := (query addTable: self keyTable withAllFields joinedWithField: self indexField) last].

	^query
]

{ #category : #'actions-internal' }
SSWDBStaticDictionarySpec >> recoverCollectionForProxy: aCollectionProxy [

	"Recover a collection of instances; return the recovered collection.
	This implementation handles both base class and persistent class keys and values"

	| keyTable targetTable statement collection entries |

	statement := self readStatement.
	collection := self newCollection.
	entries := OrderedCollection new.
	self keyClass isPersistentBaseClass ifFalse: [keyTable := self keyTableForRead].
	self targetClass isPersistentBaseClass ifFalse: [targetTable := self targetTable].

	statement values: (Array with: aCollectionProxy _ownerID).
	self reStore rowsFromStatement: statement do:
		[ :row || entry |
		entry := self createNonProxiedInstanceFromRow: row.
		entry index isDBProxy ifTrue: 
			["Untouched and possibly unrecovered proxy - use the row data appropriately"
			entry index _isRecovered 
				ifTrue: [entry index _refreshFromRow: row table: keyTable]
				ifFalse: [keyTable recoverInstanceFromRow: row into: entry index]].
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

{ #category : #'actions-internal' }
SSWDBStaticDictionarySpec >> refreshCollectionWithContentsIfUpdatedForProxy: aCollectionProxy [

	"Refresh the receiver collection and its contents if they have been updated
	Return the refreshed contents, i.e. the collection itself.
	This implementation handles both base class and persistent class keys and values"

	| collection entries keyVersionField valueVersionField statement |

	"Without versioning we revert to a standard withContents refresh"
	self reStore supportsVersioning ifFalse: [^self refreshCollectionWithContentsForProxy: aCollectionProxy].

	"No persistent class - just read"
	(self targetClass isPersistentBaseClass and: [self keyClass isPersistentBaseClass]) ifTrue: [^self recoverBaseClassCollectionForProxy: aCollectionProxy].

	"Key or Value is persistent class - refresh as opposed to read - just fetch the IDs"
	collection := self newCollection.
	entries := OrderedCollection new.

	statement := self refreshWithContentsIfUpdatedStatement.
	statement values: (Array with: aCollectionProxy _ownerID).

	self keyClass isPersistentBaseClass ifFalse: [keyVersionField := self keyTableForRefresh versionControlField].
	self targetClass isPersistentBaseClass ifFalse: [valueVersionField := self targetTable versionControlField].

	self reStore rowsFromStatement: statement do:
		[ :row || entry |
		entry := self createNonProxiedInstanceFromRow: row.
		(entry index isDBProxy and: [entry index _isRecovered and: [entry index _version < (row lookupField: keyVersionField)]]) ifTrue:
			["Out-of-date key object - forget it"
			entry index _forgetProxiedObject].
		(entry target isDBProxy and: [entry target _isRecovered and: [entry target _version < (row lookupField: valueVersionField)]]) ifTrue:
			["Out-of-date value object - forget it"
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
SSWDBStaticDictionarySpec >> refreshWithContentsIfUpdatedQuery [

	| query |

	query := super refreshWithContentsIfUpdatedQuery.
	self keyClass isPersistentBaseClass ifFalse: [keyTableForRefresh := (query addTable: self keyTable withIDAndVersionFields joinedWithField: self indexField) last].

	^query
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> setKeyClass: aClass [

	"Double-despatch to the argument"
	
	aClass beKeyClassOf: self

]
