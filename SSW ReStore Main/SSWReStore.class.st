"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStore',
	#superclass : 'Object',
	#instVars : [
		'connection',
		'tableCache',
		'nextIDCache',
		'nextIDStatement',
		'proxyCache',
		'transactionClass',
		'transaction',
		'objectProxyClass',
		'dbTableNames',
		'transactionMutex',
		'supportsFullTableRecords',
		'readAllBatchSize',
		'affiliations',
		'isDebugging'
	],
	#classInstVars : [
		'globalDefault',
		'activeReStores',
		'isDebugging'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'events' }
SSWReStore class >> activated: anSSWReStore [

	self activeReStores add: anSSWReStore.
	anSSWReStore beFinalizable
]

{ #category : 'accessing' }
SSWReStore class >> activeReStores [

	"activeReStores stores a WeakIdentitySet of all instances of the receiver that are active (have allocated proxies)"

	^activeReStores
]

{ #category : 'accessing' }
SSWReStore class >> affiliateFor: anObject [

	"Return the ReStore instance affiliated with anObject, or nil if none"

	^self activeReStores detect: [ :each | each isAffiliatedWith: anObject] ifNone: [nil]
]

{ #category : 'accessing' }
SSWReStore class >> affiliatedDefault [

	"Private - Return the ReStore instance affiliated with the current state of the system (as determined by the affiliations themselves)"

	^self activeReStores detect: [ :each | each hasActiveAffiliation] ifNone: [nil]
]

{ #category : 'events' }
SSWReStore class >> deactivated: anSSWReStore [

	self activeReStores remove: anSSWReStore ifAbsent: [nil].
	anSSWReStore beUnfinalizable
]

{ #category : 'accessing' }
SSWReStore class >> default [

	"Return the default ReStore instance. This may be a private default for the current state of the system, or the global default"

	self affiliatedDefault ifNotNil: [ :affiliatedDefault | ^affiliatedDefault].

	self globalDefault isConnected ifFalse: [self error: 'ReStore not connected'].

	^globalDefault
]

{ #category : 'accessing' }
SSWReStore class >> enterDebugMode [

	"Activate debugging for all active and future instances"

	self 
		isDebugging: true;
		setDebugMode
]

{ #category : 'accessing' }
SSWReStore class >> globalDefault [

	"Private - Return the global default ReStore instance (i.e. the default for all processes not requiring their own private default), creating it if necessary. 
	Many (most?) applications will only use a single ReStore; having a default instance means it no longer needs to passed around as a parameter"

	^globalDefault ifNil: [globalDefault := self new]
]

{ #category : 'initialize/release' }
SSWReStore class >> initialize [

	SessionManager current when: #sessionStarted send: #onStartup to: self.
	self 
		reset;
		resetActive
]

{ #category : 'initialize/release' }
SSWReStore class >> initializeReStoreGlobal [

	self class environment at: #ReStore put: self globalDefault
]

{ #category : 'accessing' }
SSWReStore class >> isDebugging [

	"Default setting for isDebugging status of instances.
	See instance implementation for further details"

	^isDebugging ifNil: [false]
]

{ #category : 'accessing' }
SSWReStore class >> isDebugging: aBoolean [

	"Default setting for isDebugging status of instances.
	See instance implementation for further details"

	isDebugging := aBoolean
]

{ #category : 'accessing' }
SSWReStore class >> leaveDebugMode [

	"Deactivate debugging for all active and future instances"

	self 
		isDebugging: false;
		setDebugMode
]

{ #category : 'instance creation' }
SSWReStore class >> new [

	^super new
		clearProxyCache;
		clearDBTableNames;
		clearTableCache;
		setDefaultDebugMode;
		yourself
]

{ #category : 'events' }
SSWReStore class >> onStartup [

	self activeReStores do: [ :each | each onStartup]
]

{ #category : 'accessing' }
SSWReStore class >> reStoreForObject: anObject ifNone: aBlock [

	"Locate and return the instance of the receiver's activeReStores in which anObject is persistent.
	If none found, return the result of evaluating aBlock"
	
	^(self proxyForObject: anObject ifNone: [nil]) 
		ifNil: [aBlock value]
		ifNotNil: [ :proxy | proxy _reStore]

]

{ #category : 'accessing' }
SSWReStore class >> reset [

	"Reset the default instance"

	globalDefault isNil ifFalse: 
		[globalDefault isConnected ifTrue: [globalDefault disconnect].
		globalDefault := nil].

	self initializeReStoreGlobal
]

{ #category : 'initialize/release' }
SSWReStore class >> resetActive [

	activeReStores := WeakIdentitySet new
]

{ #category : 'initialize/release' }
SSWReStore class >> setDebugMode [

	"Private - Put all active instances into the current debug mode"
	self activeReStores do: [ :each | each setDefaultDebugMode]
]

{ #category : 'proxy manipulation' }
SSWReStore >> _activeProxyForObject: anObject ifNone: aBlock [

	"Private - Locate and return the proxy object wrapping anObject, or the result of a Block if none"

	^anObject isDBProxy 
	ifTrue: 
		["Possibly flipped whilst waiting for the lock" 
		anObject]
	ifFalse: 
		["We only need to lookup proxies if they are active in the current transaction (since all external references to the proxy will have swapped to its proxied object).
		Therefor we only need to check in the active transaction"
		self transaction
			ifNil: [aBlock value]
			ifNotNil: [ :trans | trans proxyForObject: anObject ifNone: aBlock]]
]

{ #category : 'transaction management' }
SSWReStore >> _rollbackObjects: aCollection [

	[self beginTransaction.
	aCollection do: [ :each | each _rollbackIn: self]] ensure: [self rollbackTransaction]
]

{ #category : 'transaction api' }
SSWReStore >> abandonTransaction [

	self hasTransaction ifFalse: [self error: 'No transaction to abandon'].

	self transactionCritical:
		[self transaction abandon.
		self transaction: self transaction ownerTransaction.
		self connection rollbackTxn]
]

{ #category : 'proxy manipulation' }
SSWReStore >> activeProxyForObject: anObject ifNone: aBlock [

	"Locate and return the proxy object wrapping anObject, or the result of a Block if none"

	"Directly-persisted objects are never proxified"
	anObject class isDirectlyPersisted ifTrue: [aBlock value].
	
	^self 
		transactionCritical: [self _activeProxyForObject: anObject ifNone: aBlock]
		ifLocked:
			["Prevent lock-ups when in debugger or otherwise semi-permanently blocked"
			(self transactionMutex owner ifNil: [true] ifNotNil: [ :process | process isExpectedToResumePromptly])
				ifTrue: ["Wait" self transactionCritical: [self _activeProxyForObject: anObject ifNone: aBlock]]
				ifFalse: ["Bypass" self _activeProxyForObject: anObject ifNone: aBlock]]
]

{ #category : 'class maintenance' }
SSWReStore >> addClass: aClass [

	"Add aClass as a persistent class known to the receiver.
	If the class is already known, this will refresh its SSWDBTable.
	
	Return the table created by the addition"
	
	| table |
	
	table := aClass tableIn: self.
	table isNil ifTrue: [^nil].

	"Remove any pre-existing table"
	self forgetClass: aClass.

	"Must add the root class of a persistent hierarchy before adding a subclass"
	(table isRootTable or: [self tableCache includesKey: table rootClass]) ifFalse:
		[self addClass: table rootClass].

	"Validate"
	self validateTable: table.

	table postCreate.

	"Add it"
	self tableCache at: aClass put: table.

	"Added - now validate containedTables"
	table containedTables do: [ :each | self validateTable: each].

	^table
]

{ #category : 'class maintenance' }
SSWReStore >> addClassWithSubclasses: aClass [

	"Add aClass and all its subclasses as persistent classes known to the receiver"
	
	aClass withAllSubclasses do: [ :class | self addClass: class]
]

{ #category : 'class maintenance' }
SSWReStore >> addClasses: aCollection [

	aCollection do: [ :each | self addClass: each]
]

{ #category : 'initialize/release' }
SSWReStore >> affiliateWith: anObject using: aBlock [

	self affiliations at: anObject put: aBlock
]

{ #category : 'accessing' }
SSWReStore >> affiliations [

	"affiliations stores a weak-keyed Dictionary where the key is an object with which the receiver is 'affiliated' such that it is that object's default ReStore instance. 
	The correponding value is a 1-arg block which is evaluated with the key object; this should return true if the affiliation is in force. 
	This mechanism is used primarily to provide process-specific default ReStore instances - see Process>>reStore: for more details.
	It can also be used to implement default ReStore instances for other current/active objects, e.g. the current session in a web application framework"

	^affiliations ifNil: [affiliations := WeakIdentityDictionary newWithWeakKeys: 16]
]

{ #category : 'cache management' }
SSWReStore >> allocateIDFor: anObject in: aDBTable [

	^anObject reStoreNewUniqueID ifNil: [self transaction allocateIDFor: anObject tableRecord: (self tableRecordFor: aDBTable)]
]

{ #category : 'class maintenance' }
SSWReStore >> alterInstVar: aSymbol in: aClass [

	"Alter the definition of the column corresponding to oldInstVar (a Symbol) in aClass to match its current type definition.
	This will use the database's default transfomation from the old to the new type which may result in data loss.
	Use changedClassOfInstVar:in:modifyUsing: for explicit data conversion"

	| table field columns definitionTable |

	"Ensure the receiver is up-to-date with the definition of aClass"
	table := self addClass: aClass.

	"Check old iv field already exists"
	field := table fieldAccessing: aSymbol.
	columns := self columnsInTable: table.
	(columns anySatisfy: [ :col | col name asUppercase = field name asUppercase]) ifFalse:
		[(self error: 'No column corresponding to inst var ', aSymbol)].

	definitionTable := table rootTable forCreation.
	definitionTable == table 
		ifTrue: [self addClass: aClass]
		ifFalse: [self addClassWithSubclasses: definitionTable instanceClass].

	self evaluateInTxn: 
		[self sqlDialect alterField: field table: definitionTable in: self.
		true]
]

{ #category : 'read/write objects' }
SSWReStore >> applyUpdates: anSSWSQLCollection toObject: anSSWDBObjectProxy [

	"Return a Boolean indicating whether the update succeeds"

	| query statement |

	query := SSWSQLUpdateObjectQuery forObject: anSSWDBObjectProxy withUpdates: anSSWSQLCollection.
	statement := self transaction statementForUpdateQuery: query ifAbsent: [self prepareStatementForQuery: query].

	"If the update query succeeds, exactly 1 row should be affected"
	statement values: query values; exec.
	^statement rowsAffected = 1
]

{ #category : 'connection' }
SSWReStore >> attachTo: aConnection [

	"Attach the receiver to aConnection (probably, but not necessarily, already-connected)"

	self connection: aConnection.
	self connect
]

{ #category : 'transaction management' }
SSWReStore >> beginDumbTransaction [

	"Begin a dumb transaction to absorb object traversals"
	
	self transaction: (SSWDBDumbTransaction new begin; yourself)
]

{ #category : 'transaction api' }
SSWReStore >> beginTransaction [

	self transactionCritical: 
		[self softRollback.

		self transaction: 
			(self transactionClass new
				beginWithin: self transaction;
				yourself)]
]

{ #category : 'cache management' }
SSWReStore >> cacheObject: aPersistentObjectProxy [

	"Add the given persistent object proxy to the receiver's cache"
	
	"Use _class to avoid fetching inherited objects (issue#0015)"
	(self classCacheFor: aPersistentObjectProxy _class) at: aPersistentObjectProxy _id put: aPersistentObjectProxy
]

{ #category : 'querying' }
SSWReStore >> cachedInstancesOf: aClass [

	"Careful with this - despite the naming similarity to instancesOf: it is only intended for use with refreshObjects: and related methods"

	^(self classCacheFor: aClass) values
]

{ #category : 'cache management' }
SSWReStore >> cachedObjectOfClass: aClass withID: aRawID ifAbsent: aBlock [

	"Return the cached object (actually a proxy) of the given class with the given unique ID (raw value as read from database; may need reifying).
	If none is found, evaluate aBlock"
	
	^self transactionCritical: [(self classCacheFor: aClass) at: (aClass reStoreIDClass instanceFromDBValue: aRawID in: self) ifAbsent: aBlock]
]

{ #category : 'cache management' }
SSWReStore >> cachedObjectOfClass: aClass withID: aRawID 
	ifAbsent: absentBlock ifUnrecovered: unrecoveredBlock ifUntouched: untouchedBlock [

	"Return the cached object (which may actually a proxy) of the given class with the given unique ID (raw value as read from database; may need reifying).
	If none is found, evaluate absentBlock.
	If an unrecovered proxy, evaluate unrecoveredBlock with it.
	If a recovered but not 'touched' proxy, evaluate untouchedBlock with it.
	A proxy is considered 'touched' if it has been sent a message since the last abort"
	
	^self transactionCritical:
		[(self cachedObjectOfClass: aClass withID: aRawID ifAbsent: [nil])
		ifNil:
			[absentBlock value]
		ifNotNil:
			[ :proxy |
			proxy isDBProxy ifTrue:
				[proxy _isRecovered 
					ifTrue: [untouchedBlock value: proxy]
					ifFalse: [unrecoveredBlock value: proxy]].
			proxy]]
]

{ #category : 'class maintenance' }
SSWReStore >> changedClassOfInstVar: aSymbol in: aClass modifyUsing: aBlock [

	"The definition of the inst var named aSymbol in aClass has changed.
	Modify the column definition corresponding to aSymbol, using aBlock to modify existing records"

	| table definitionTable origField columns |

	"Ensure the receiver is up-to-date with the definition of aClass"
	table := self addClass: aClass.

	"Check field exists"
	origField := table fieldAccessing: aSymbol.
	columns := self columnsInTable: table.
	(columns anySatisfy: [ :col | col name asUppercase = origField name asUppercase]) ifFalse:
		[(self error: 'No column corresponding to inst var ', aSymbol)].

	definitionTable := table rootTable forCreation.

	self evaluateAsTxn: 
		[| tempField updator |
		"Add a new column to hold the modified data"
		tempField := table addDataField: 
						(SSWDBStaticField new
							name: 'TEMP__';
							targetClass: origField targetClass;
							accessor: ((self sqlDialect instVarAccessorFor: aClass) access: aSymbol in: aClass);
							yourself).
		tempField accessor name: #temp__.
		definitionTable == table ifFalse: [definitionTable addDataField: tempField].
		self sqlDialect addFields: (Array with: tempField) to: definitionTable in: self. 
		
		"Modify the data"
		(self instancesOf: aClass) modify: [ :each | each temp__: (aBlock value: each)].

		"Drop the original column with the original definition"
		self sqlDialect dropColumnNamed: origField name fromTable: definitionTable in: self.

		"Re-add the column with its new definition"
		self sqlDialect addFields: (Array with: origField) to: definitionTable in: self. 
		
		"Copy the data back from the temp column"
		updator := (aSymbol, ':') asSymbol.
		(self instancesOf: aClass) modify: [ :each | each perform: updator with: each temp__].

		"Re-add class to remove temp field, and drop it"
		definitionTable == table 
			ifTrue: [self addClass: aClass]
			ifFalse: [self addClassWithSubclasses: definitionTable instanceClass].
		self sqlDialect dropColumnNamed: tempField name fromTable: definitionTable in: self.
		true]
]

{ #category : 'cache management' }
SSWReStore >> classCacheFor: aClass [

	"Return the subcache of the receiver's proxyCache responsible for caching
	proxied instances of aClass"
	
	"Proxies are cached under the registerClass of their associated table"
	^self proxyCache at: aClass ifAbsentPut:
		[self proxyCache 
			at: (self tableForClass: aClass) registerClass 
			ifAbsentPut: [WeakLookupTable new: 128]]
]

{ #category : 'cache management' }
SSWReStore >> clearAllCaches [

	self
		clearProxyCache;
		clearNextIDCache;
		clearTransaction;
		clearDBTableNames;
		clearStatementCache
]

{ #category : 'cache management' }
SSWReStore >> clearDBTableNames [

	self dbTableNames: nil
]

{ #category : 'cache management' }
SSWReStore >> clearNextIDCache [

	self nextIDCache: IdentityDictionary new
]

{ #category : 'cache management' }
SSWReStore >> clearProxyCache [

	self proxyCache: IdentityDictionary new
]

{ #category : 'cache management' }
SSWReStore >> clearStatementCache [

	nextIDStatement ifNotNil: 
		[ :stmt |
		stmt free.
		self nextIDStatement: nil].

	self tableCache do: [ :each | each freePreparedStatements]
]

{ #category : 'cache management' }
SSWReStore >> clearTableCache [

	self 
		tableCache: IdentityDictionary new;
		clearNextIDCache
]

{ #category : 'transaction management' }
SSWReStore >> clearTransaction [

	self transaction: nil
]

{ #category : 'connection' }
SSWReStore >> clearTxn [

	"Clear down any active database txn (transaction)"

	[self connection rollbackTxn] on: Error do: [ :exc | exc return: nil]
]

{ #category : 'connection' }
SSWReStore >> columnsForFields: aCollectionOfDBFields [

	^self connection columnsForFields: aCollectionOfDBFields
]

{ #category : 'connection' }
SSWReStore >> columnsInTable: anSSWDBTable [

	^self connection columnsInTable: anSSWDBTable
]

{ #category : 'transactionless api' }
SSWReStore >> commit: anObject [

	"Commit changes to anObject"

	^self commitAll: {anObject}
]

{ #category : 'transactionless api' }
SSWReStore >> commitAll: aCollection [

	"Alternative transaction model - commit any changes made to the members of aCollection.

	Note if a transaction is in progress (e.g. manually started with beginTransaction) the changes are added to this active transaction and *not* committed at this stage.
	This allows transaction and transactionaless APIs to be mixed.

	Return success"

	^self transactionCritical:
		[self evaluateInTransaction: [aCollection do: [ :each | each _commitIn: self]]]
]

{ #category : 'transaction api' }
SSWReStore >> commitTransaction [

	"Trap and attempt to recover from errors during commit (Issue#0023)"

	self isTransactionInProgress ifFalse: [self error: 'No transaction in progress'].

	^self transactionCritical:
		[| success |

		[self transaction prepareToCommit] on: Error do: [ :exc | SSWDBTransactionPreCommitError signalWith: exc in: self].

		success := 
			[self transaction commitTo: self connection.
			self transaction hasFailedCommit not] on: Error do: [ :exc | SSWDBTransactionCommitError signalWith: exc in: self].

		success ifTrue: [self transaction: self transaction ownerTransaction].
	
		success]
]

{ #category : 'connection' }
SSWReStore >> connect [

	"Connect to the database, initializing the receiver"

	self objectProxyClass isNil ifTrue: [self setDefaultTransactionMode].

	self isConnected ifFalse: [self openConnection].

	self postConnect
]

{ #category : 'accessing' }
SSWReStore >> connection [

	"connection stores the DBConnection with which the receiver communicates with the database"
	
	^connection
]

{ #category : 'accessing' }
SSWReStore >> connection: aDBConnection [

	"connection stores the DBConnection with which the receiver communicates with the database"
	
	connection := aDBConnection
]

{ #category : 'proxy manipulation' }
SSWReStore >> createProxyForNewObject: anObject [

	"Create and return a proxy for the given non-persistent object.
	Error if no active transaction (issue#0022)"

	| proxy table id |

	(self hasTransaction and: [self transaction canCommit]) ifFalse:
		[self error: 'Cannot store an object outside of a transaction'].

	proxy := (self objectProxyClassFor: anObject class) _forNewObject: anObject withID: nil inReStore: self.

	table := self tableForClass: anObject class.
	id := table idDataField ifNotNil: [ :idDataField | idDataField accessor valueIn: anObject].
	id isNil 
	ifTrue: 
		[proxy _id: (self allocateIDFor: anObject in: table)]
	ifFalse: 
		[((self classCacheFor: anObject class) includesKey: id) ifTrue: [self error: 'attempt to store object of class <1d> with duplicate ID <2p>' << {anObject class. id}].
		proxy _id: id].

	proxy _intern.

	^proxy
]

{ #category : 'proxy manipulation' }
SSWReStore >> createProxyForObjectOfClass: aClass withID: anInteger [

	"Return an unrecovered proxy for the given class/ID"
	
	^((self objectProxyClassFor: aClass)
		 _forObjectOfClass: aClass withID: anInteger inReStore: self)
			_intern;
			yourself
]

{ #category : 'proxy manipulation' }
SSWReStore >> createProxyForRow: aDBRow fromTable: aDBTable withID: anInteger [

	"Patched for issue 120-xxx	_intern the proxy before recovery (in case it directly references itself)
	
	Return a recovered proxy for the object persisted in the given row"
	
	| proxy |
	
	proxy := (self objectProxyClassFor: aDBTable instanceClass) 
			_forObjectOfClass: aDBTable instanceClass withID: anInteger inReStore: self.
	
	proxy _intern.

	aDBTable recoverInstanceFromRow: aDBRow into: proxy.
	
	^proxy yourself		
]

{ #category : 'class maintenance' }
SSWReStore >> createTableRecordFor: anSSWDBTable [

	"Private - Create in the database the DBTableRecord for aClass."

	| record |
	
	record := SSWDBCachingObjectProxy new 
			_reStore: self;
			_class: SSWDBTableRecord;
			_proxiedObject: anSSWDBTable tableRecord; 
			yourself.

	anSSWDBTable instanceClass = SSWDBTableRecord
		ifTrue: [record _id: 0]
		ifFalse: [record _id: (self nextIDForTable: (self tableForClass: SSWDBTableRecord))].

	self evaluateInTxn: [self insertProxy: record. true]
]

{ #category : 'connection' }
SSWReStore >> dbErrorClass [

	^self connection dbErrorClass
]

{ #category : 'testing' }
SSWReStore >> dbIncludesTable: aDBTable [

	^(self dbTableNamesFor: aDBTable namespace) includes: aDBTable name asUppercase
]

{ #category : 'class maintenance' }
SSWReStore >> dbIncludesTableForClass: aClass [

	^(self tableForClass: aClass ifAbsent: [nil])
		ifNil: [false]
		ifNotNil: [ :table | self dbIncludesTable: table]
]

{ #category : 'accessing' }
SSWReStore >> dbTableNames [

	"dbTableNames stores a Dictionary mapping database namespaces (schemas/databases, empty String for the default) to collections of table names (Strings) in that namespace'.
	This is cached for use by client methods as it can be an expensive operation.

	Lazy initialized; methods which may change the DB's table definitions should reset this to nil"
	
	^dbTableNames ifNil: [dbTableNames := Dictionary new]
]

{ #category : 'accessing' }
SSWReStore >> dbTableNames: aCollectionOrNil [

	"dbTableNames stores a Dictionary mapping database namespaces (schemas/databases, empty String for the default) to collections of table names (Strings) in that namespace'.
	This is cached for use by client methods as it can be an expensive operation.

	Lazy initialized; methods which may change the DB's table definitions should reset this to nil"
	
	dbTableNames := aCollectionOrNil
]

{ #category : 'class maintenance' }
SSWReStore >> dbTableNamesFor: aNamespaceOrNil [

	^self dbTableNames at: (aNamespaceOrNil ifNil: ['']) ifAbsentPut: [(self connection tablesInNamespace: aNamespaceOrNil) collect: [ :each | each asUppercase]]
]

{ #category : 'connection' }
SSWReStore >> debugTo: aStreamOrNil [

	"Set the debug (logging) mode of the receiver:
	 - if the parameter is aStream, all executed SQL is logged to that Stream.
	- if nil, debugging is deactivated"

	self connection debugStream: aStreamOrNil
]

{ #category : 'constants' }
SSWReStore >> defaultReadAllBatchSize [

	^100
]

{ #category : 'proxy manipulation' }
SSWReStore >> deferredObjectOfClass: aClass withID: anInteger [

	"Return the object with the given class/ID from the receiver's proxyCache.
	If not present, create, cache and return an unrecovered (deferred) proxy for that object"
	
	^self cachedObjectOfClass: aClass withID: anInteger ifAbsent:
		[self createProxyForObjectOfClass: aClass withID: anInteger]
]

{ #category : 'proxy manipulation' }
SSWReStore >> deferredObjectOfClass: aClass withID: anInteger version: versionInteger [

	"Return the object with the given class/ID from the receiver's proxyCache.
	If not present, create, cache and return an unrecovered (deferred) proxy for that object.
	If present and untouched, but with an earlier version than versionInteger, forget the current object"
	
	^self 
		cachedObjectOfClass: aClass
		withID: anInteger 
		ifAbsent: [self createProxyForObjectOfClass: aClass withID: anInteger]
		ifUnrecovered: [ :proxy | proxy]
		ifUntouched: [ :proxy | proxy _version < versionInteger ifTrue: [proxy _forgetProxiedObject]. proxy]
]

{ #category : 'read/write objects' }
SSWReStore >> deleteProxy: aProxydObject [

	"Delete aProxydObject from the database"

	| query statement |

	(self transaction isAlreadyDeleted: aProxydObject) ifTrue: [^self].

	query := SSWSQLDeleteObjectQuery forObject: aProxydObject.

	statement := aProxydObject _dbTable deleteStatementGeneratedFrom: query.
	statement values: query values.
	statement exec; close.

	self transaction addDeletedObject: aProxydObject
]

{ #category : 'proxy manipulation' }
SSWReStore >> deregisterProxy: anSSWDBObjectProxy [

	self uncacheObject: anSSWDBObjectProxy
]

{ #category : 'class maintenance' }
SSWReStore >> destroyAllClasses [

	"USE WITH EXTREME CAUTION.
	Also understand the difference between this method and destroyAllTables"

	| droppedTables |

	droppedTables := OrderedCollection new.

	[self evaluateAsTxn:
		[self tableCache keysAndValuesDo: 
			[ :class :table | 
			(self isSystemClass: class) ifFalse: 
				[droppedTables addAll: table removeDefinition]].
		true].
	self evaluateAsTransaction: [self unstoreNextIDsForTables: droppedTables]] ensure: [self clearDBTableNames]
]

{ #category : 'class maintenance' }
SSWReStore >> destroyAllTables [

	"USE WITH EXTREME CAUTION - DEPENDING ON YOUR DATABASE - THIS MAY DELETE REQUIRED SYSTEM TABLES.
	Unlike destroyAllClasses (which only removes the tables of classes known to the receiver)
	this method will remove ABSOLUTELY ALL TABLES from the database"

	[self evaluateAsTxn:
		[self dbTableNames do: [ :tableNames | tableNames do: [ :tableName | [self executeSQL: ('DROP TABLE ', tableName)] on: self connection dbErrorClass do: [ :exc | exc return]]].
		true]] 
			ensure: [self clearDBTableNames]
]

{ #category : 'class maintenance' }
SSWReStore >> destroyClass: aClass [

	"Remove from the database the definition(s) of the table(s) associated with the given class"

	| table |

	table := self tableForClass: aClass.

	table isRootTable 
		ifTrue: [self destroyTable: table]
		ifFalse: [(self instancesOf: aClass) unstoreAll]
]

{ #category : 'class maintenance' }
SSWReStore >> destroyTable: aTable [

	"Remove from the database the definition of the given table (and any associated tables)"

	[self evaluateAsTxn: 
		[| droppedTables |
		droppedTables := aTable removeDefinition. 
		self unstoreNextIDsForTables: droppedTables.
		true]] ensure: [self clearDBTableNames]
]

{ #category : 'connection' }
SSWReStore >> detach [

	"Detach the receiver from its connection, returning the connection.
	The connection is left connected for potential reuse"

	| oldConnection |

	self mustBeConnected.

	oldConnection := self connection.

	self 
		clearTxn;
		debugTo: nil;
		connection: nil;
		postDisconnect.

	^oldConnection
]

{ #category : 'initialize/release' }
SSWReStore >> disaffiliateWith: anObject [

	self affiliations removeKey: anObject ifAbsent: [self error: 'not affiliated with ', anObject printString]
]

{ #category : 'connection' }
SSWReStore >> disconnect [

	"Disconnect from the database and clear all caches"
	
	self mustBeConnected.

	self hardDisconnect
]

{ #category : 'class maintenance' }
SSWReStore >> enableFullTableRecords [

	"Enable the use of full table records - intended for existing databases without this enabled"

	self supportsFullTableRecords ifTrue: [self error: 'Full table records already enabled'].

	self supportsFullTableRecords: true.
	self addClass: SSWDBTableRecord.

	"Separate transactions to ensure column names are updated"
	self 
		evaluateAsTxn: [(self tableForClass: SSWDBTableRecord) synchronizeDefinition. true];
		evaluateAsTxn: 
			[((self instancesOf: SSWDBTableRecord) satisfying: [ :each | each fullTableName = nil]) modify: [ :each | each fullTableName: each tableName].
			true]

]

{ #category : 'initialize/release' }
SSWReStore >> ensureCanChangeTransactionMode [

	"Cannot change mode if connected to DB"

	self isConnected ifTrue: [self error: 'Cannot change transaction mode whilst connected']
]

{ #category : 'proxy manipulation' }
SSWReStore >> ensureIsActiveInCurrentTransaction: anObject [

	^self transaction ensureIsActive: anObject
]

{ #category : 'transaction management' }
SSWReStore >> ensureNoActiveTransaction [

	self hasTransaction ifTrue:
		[self transaction isDumb
			ifTrue: [self rollbackTransaction]
			ifFalse: [self error: 'Active transaction - cannot proceed']]
]

{ #category : 'debugging' }
SSWReStore >> enterDebugMode [

	self isDebugging: true
]

{ #category : 'transaction api' }
SSWReStore >> evaluateAsTransaction: aBlock [

	"Return whether the commit succeeded"
	
	^[self beginTransaction.
	aBlock value.
	self commitTransaction] ifCurtailed: [self rollbackTransaction]
]

{ #category : 'transaction api' }
SSWReStore >> evaluateAsTransactionUntilSuccess: aBlock [

	"Evaluate aBlock within a transaction then commit.
	If the commit fails, rollback and refresh the transaction 
	and re-evaluate aBlock until the commit succeeds"

	self transactionCritical:	
		[[[self beginTransaction.
		aBlock value.
		self commitTransaction] whileFalse:
			[self rollbackAndRefreshTransaction]] ifCurtailed: [self rollbackTransaction]]
]

{ #category : 'connection' }
SSWReStore >> evaluateAsTxn: aBlock [

	"Evaluate aBlock within a database transaction (Txn in Dolphin DBConnect parlance).
	aBlock should evaluate to aBoolean indicating the success of its operation.
	If true, the transaction is committed, if false it is rolled back"

	^self connection evaluateAsTxn: aBlock
]

{ #category : 'transaction api' }
SSWReStore >> evaluateInTransaction: aBlock [

	"Evaluate aBlock within a transaction:
	 - if there is currently a transaction in progress just evaluate aBlock
	 - if there is no transaction in progress, begin and commit one around aBlock
	Return success (presumed in the case of the former).

	Note the subtle difference from evaluateAsTransaction: which always begins and commits a new transaction (erroring if there is already one in progress)"
	
	^self isTransactionInProgress
		ifTrue: [aBlock value. true]
		ifFalse: [self evaluateAsTransaction: aBlock]
]

{ #category : 'connection' }
SSWReStore >> evaluateInTxn: aBlock [

	"Private - If the receiver's connection is currently within a txn (database transaction),
	evaluate aBlock within that transaction, otherwise begin and commit a txn around aBlock"

	^self connection hasTxn
		ifTrue: [aBlock value]
		ifFalse: [self evaluateAsTxn: aBlock]
]

{ #category : 'connection' }
SSWReStore >> executeQuery: anSSWSQLQuery [

	"Execute the given query.
	If it is a read query, return the DBResultSet (client code should close this when done)
	If it is a write query, return the number of rows affected"

	^self executeQuery: anSSWSQLQuery cursorType: nil
]

{ #category : 'connection' }
SSWReStore >> executeQuery: anSSWSQLQuery cursorType: aSymbol [

	"Execute the given query.
	If it is a read query, return the DBResultSet (client code should close this when done); aSymbol indicates the type of cursor for streaming/incremental read (may be nil)
	If it is a write query, return the number of rows affected"

	^self transactionCritical:
		[| statement |
		statement := self connection executeQuery: anSSWSQLQuery cursorType: aSymbol.
		anSSWSQLQuery isReadQuery
			ifTrue: [statement results]
			ifFalse: [[statement rowsAffected] ensure: [statement free]]]
]

{ #category : 'connection' }
SSWReStore >> executeSQL: aString [

	^self connection exec: aString
]

{ #category : 'connection' }
SSWReStore >> executeSQLAsTxn: aCollectionOfStrings [

	"Raw SQL execution - for privileged clients only"

	self evaluateAsTxn:
		[aCollectionOfStrings do: [ :aString | self executeSQL: aString].
		true]
]

{ #category : 'connection' }
SSWReStore >> executeSQLFrom: aBlock [

	"Evaluate aBlock with a new SQLWriteStream, evaluating the contents.
	Raw SQL execution - for privileged clients only"

	| stream |

	stream := self sqlDialect sqlWriteStream.
	aBlock value: stream.
	^self executeSQL: stream contents
]

{ #category : 'querying' }
SSWReStore >> fetchObjectOfClass: aClass withQuery: anSSWSQLQuery ifNone: aBlock [

	| row |
	
	row := self rowFromQuery: anSSWSQLQuery.
	
	^row isNil
		ifTrue: [aBlock value]
		ifFalse: [self objectFromRow: row table: (self tableForClass: aClass)]
]

{ #category : 'querying' }
SSWReStore >> fetchObjectsFromTable: aDBTable withQuery: anSSWSQLQuery into: aCollection [

	self rowsFromQuery: anSSWSQLQuery do: [ :row | aCollection _dbAdd: (self objectFromRow: row table: aDBTable)]
]

{ #category : 'querying' }
SSWReStore >> fetchObjectsOfClass: aClass withQuery: anSSWSQLQuery into: aCollection [

	^self fetchObjectsFromTable: (self tableForClass: aClass) withQuery: anSSWSQLQuery into: aCollection
]

{ #category : 'querying' }
SSWReStore >> fetchObjectsOfClass: aClass withStatement: aDBPreparedStatement into: aCollection [

	| table |
		
	table := self tableForClass: aClass.

	self 
		rowsFromStatement: aDBPreparedStatement 
		keysAndValuesDo: [ :index :row | aCollection _dbAdd: (self objectFromRow: row table: table) suggestedIndex: index]
]

{ #category : 'connection' }
SSWReStore >> finalize [

	"Ensure the receiver is disconnected prior to GC  (issue#0016)"

	[self disconnect] on: Error do: [ :sig | "Ignore possible 'not connected' error; refactor to avoid this" sig return: nil]	
]

{ #category : 'transactionless api' }
SSWReStore >> forceRefresh: anObject [

	self forceRefreshAll: {anObject}
]

{ #category : 'transactionless api' }
SSWReStore >> forceRefreshAll: aCollection [

	self transactionCritical:
		[self ensureNoActiveTransaction.
		self connection rollbackTxn.

		aCollection do: [ :each | each _forceRefreshIn: self]]
]

{ #category : 'class maintenance' }
SSWReStore >> forgetClass: aClass [

	(self tableCache removeKey: aClass ifAbsent: []) ifNotNil: [ :table | self connection forgetTable: table]
]

{ #category : 'class maintenance' }
SSWReStore >> fullTableRecordFor: anSSWDBTable [

	"Private - Return the TableRecord (ID manager) for the given table, using full name lookup.
	Return nil if none found"

	^self nextIDCache at: anSSWDBTable ifAbsent:
		[| record |
		anSSWDBTable isRootTable
			ifTrue: [record := (self instancesOf: SSWDBTableRecord) detect: [ :seq | seq fullTableName = anSSWDBTable fullName] ifNone: [nil]]
			ifFalse: [record := self fullTableRecordFor: anSSWDBTable rootTable].
		record isNil
			ifTrue: [nil]
			ifFalse: [self nextIDCache at: anSSWDBTable put: record]]
]

{ #category : 'debugging' }
SSWReStore >> halt [

	"Put the receiver into debug mode first"

	self enterDebugMode.
	super halt
]

{ #category : 'connection' }
SSWReStore >> hardDisconnect [

	"Disconnect from the database and clear all caches"
	
	self 
		preDisconnect;
		softDisconnect;
		postDisconnect
]

{ #category : 'testing' }
SSWReStore >> hasActiveAffiliation [

	self hasAffiliations ifFalse: [^false].

	self affiliations keysAndValuesDo: [ :affiliatedObject :testBlock | (testBlock value: affiliatedObject) ifTrue: [^true]].

	^false
]

{ #category : 'testing' }
SSWReStore >> hasAffiliations [

	^affiliations notNil
]

{ #category : 'transactionless api' }
SSWReStore >> hasChanged: anObject [

	"Return true if anObject has changes that would be persisted by commitObjects:"

	^anObject _checkHasChangedIn: self
]

{ #category : 'testing' }
SSWReStore >> hasConnection [

	^self connection notNil
]

{ #category : 'transaction management' }
SSWReStore >> hasTransaction [

	^self transaction notNil
]

{ #category : 'transaction api' }
SSWReStore >> hasTransactionChanges [

	"Critical due to hasChanges interrogating the internals of the transaction"
	^self transactionCritical: [self isTransactionInProgress and: [self transaction hasChanges]]
]

{ #category : 'transactionless api' }
SSWReStore >> haveAnyChanged: aCollection [

	"Return true if any of the objects in aCollection have changes that would be persisted by commitObjects:"

	^aCollection anySatisfy: [ :each | self hasChanged: each]
]

{ #category : 'read/write objects' }
SSWReStore >> insertProxy: aProxydObject [

	"aProxydObject is a proxy which is not yet persistent. Insert it into the database"

	| query statement |

	query := SSWSQLInsertQuery forObject: aProxydObject.

	statement := aProxydObject _dbTable insertStatementGeneratedFrom: query.
	statement values: query values.
	statement exec; close
]

{ #category : 'querying' }
SSWReStore >> instancesOf: aClass [

	^SSWDBInstancesCollection forClass: aClass in: self
]

{ #category : 'testing' }
SSWReStore >> isAffiliatedWith: anObject [

	^self hasAffiliations and: [self affiliations includesKey: anObject]
]

{ #category : 'testing' }
SSWReStore >> isClassPersistent: aClass [

	"Return a Boolean indicating whether the given class is a persistent class
	known to this reStore"
	
	^(self tableCache includesKey: aClass) or:
		"aClass is persistent if it defines a table"
		[(self addClass: aClass) notNil]
]

{ #category : 'testing' }
SSWReStore >> isConnected [

	"Pass-thru to the connection"

	^self hasConnection and: [self connection isConnected]
]

{ #category : 'accessing' }
SSWReStore >> isDebugging [

	"When isDebugging is true the receiver will adjust its behaviour to facilitate easier debugging within ReStore code. 

	Principally, when the receiver's transactionMutex is locked, if debugging is enabled the mutex will check the current execution stack when an attempt is made to enter a critical section.
	If the current execution stack is adjudged to have originated from a Debugger, Inspector or other development tool, the lock will be bypassed.
	
	Additionally, proxies adjust their response to instVarAt: to enable their internal state to be shown in the Debugger variables list"

	^isDebugging
]

{ #category : 'accessing' }
SSWReStore >> isDebugging: aBoolean [

	"When isDebugging is true the receiver will adjust its behaviour to facilitate easier debugging within ReStore code. 

	Principally, when the receiver's transactionMutex is locked, if debugging is enabled the mutex will check the current execution stack when an attempt is made to enter a critical section.
	If the current execution stack is adjudged to have originated from a Debugger, Inspector or other development tool, the lock will be bypassed.
	
	Additionally, proxies adjust their response to instVarAt: to enable their internal state to be shown in the Debugger variables list"

	isDebugging := aBoolean
]

{ #category : 'transaction management' }
SSWReStore >> isInCurrentTransaction: anObject [

	^self transaction includesProxiedObject: anObject
]

{ #category : 'testing' }
SSWReStore >> isSystemClass: aClass [

	^self persistentSystemClasses includes: aClass
]

{ #category : 'transaction api' }
SSWReStore >> isTransactionInProgress [

	^self hasTransaction and: [self transaction isDumb not]
]

{ #category : 'transactionless api' }
SSWReStore >> lazyRefresh: anObject [

	self lazyRefreshAll: {anObject}
]

{ #category : 'transactionless api' }
SSWReStore >> lazyRefreshAll: aCollection [

	"Lazy-refresh the elements of aCollection - just forget the actual objects; they will be lazily re-read (and hence refreshed) when next referenced"

	self transactionCritical:
		[self ensureNoActiveTransaction.
		self connection rollbackTxn.

		aCollection do: [ :each | each _lazyRefreshIn: self]]
]

{ #category : 'debugging' }
SSWReStore >> leaveDebugMode [

	self isDebugging: false
]

{ #category : 'connection' }
SSWReStore >> mustBeConnected [
	
	self isConnected ifFalse: [self error: 'Not connected']
]

{ #category : 'accessing' }
SSWReStore >> nextIDCache [

	"nextIDCache stores a Dictionary mapping SSWDBTables 
	to the persistent SSWDBTableRecord instance governing allocation of table IDs"
	
	^nextIDCache
]

{ #category : 'accessing' }
SSWReStore >> nextIDCache: anIdentityDictionary [

	"nextIDCache stores a Dictionary mapping SSWDBTables 
	to the persistent SSWDBTableRecord instance governing allocation of table IDs"
	
	nextIDCache := anIdentityDictionary
]

{ #category : 'cache management' }
SSWReStore >> nextIDForTable: anSSWDBTable [

	"Return the next ID for the given table, updating the table's database record accordingly.
	Usually only used for the NEXT_ID table itself"

	| tableRecord directTableRecord nextID statement |

	tableRecord := self tableRecordFor: anSSWDBTable.
	
	"Avoid invoking change detection system by referencing nextTableID directly"
	directTableRecord := tableRecord _proxiedObject.

	"Need to update nextTableID, ensuring we don't update if it has been changed by another ReStore"					
	nextID := directTableRecord nextID + 1.

	statement := self nextIDStatement.
	statement values: (Array with: nextID with: tableRecord _id with: directTableRecord nextID); exec.
	statement rowsAffected = 1 ifTrue: [^nextID].

	"Refresh and try again"
	tableRecord _recoverProxiedObject.
	^self nextIDForTable: anSSWDBTable
]

{ #category : 'accessing' }
SSWReStore >> nextIDStatement [

	^nextIDStatement ifNil: 
		[| table |
		table := self tableForClass: SSWDBTableRecord.
		nextIDStatement := 
			self prepareStatementForQuery: 
				(SSWSQLUpdateQuery new
					table: table;
					conditions: ((SSWSQLCondition field: (table fieldAccessing: #_id) equalTo: SSWSQLQueryParameter) & (SSWSQLCondition field: (table fieldAccessing: #nextID) equalTo: SSWSQLQueryParameter));
					fieldUpdates: (SSWSQLFieldAssignmentCollection with: (SSWSQLFieldAssignment field: (table fieldAccessing: #nextID) value: SSWSQLQueryParameter));
					yourself)]
]

{ #category : 'accessing' }
SSWReStore >> nextIDStatement: anObject [
	nextIDStatement := anObject
]

{ #category : 'class maintenance' }
SSWReStore >> nextShortTableNameFor: anSSWDBTable [

	"Private - Return a unique name for anSSWDBTable, within the size limits of the database"

	| subtable root counter shortName tableIDs |

	"First check - anSSWDBTable may have an already-defined subtable. Use its name"
	subtable := self tableCache detect: [ :each | each fullName = anSSWDBTable fullName] ifNone: [nil].
	subtable isNil ifFalse: [^subtable name].

	root := (anSSWDBTable name copyFrom: 1 to: (self sqlDialect maxTableNameLength - 4)), '_'.
	counter := 0.

	(self dbIncludesTableForClass: SSWDBTableRecord)
		ifTrue: [tableIDs := self instancesOf: SSWDBTableRecord]
		ifFalse: [tableIDs := #()].

	"Loop until name unique to both receiver and DB is found"
	[shortName := root, counter displayString.
	(self tableCache anySatisfy: [ :each | each definesName: shortName]) or: 
		[tableIDs anySatisfy: [ :each | each tableName = shortName]]] whileTrue: [counter := counter + 1].

	^shortName
]

{ #category : 'querying' }
SSWReStore >> objectFromRow: aDatabaseRow table: anSSWDBTable [

	"Return the proxyd object represented by the given row from the given table.
	If the required proxy object is not in the cache, create it.
	If the object is already recovered, refresh it from the row if it's not been changed in the image"
	
	^(aDatabaseRow lookupIDField: anSSWDBTable idField) ifNotNil: 
		[ :id | 
		self 
			cachedObjectOfClass: (anSSWDBTable instanceClassFromRow: aDatabaseRow)
			withID: id 
			ifAbsent: [self createProxyForRow: aDatabaseRow fromTable: anSSWDBTable withID: id]
			ifUnrecovered: [ :proxy | anSSWDBTable recoverInstanceFromRow: aDatabaseRow into: proxy]
			ifUntouched: [ :proxy | proxy _refreshFromRow: aDatabaseRow table: anSSWDBTable]]
]

{ #category : 'accessing' }
SSWReStore >> objectProxyClass [

	"objectProxyClass stores the class of Proxy to use for Objects (as opposed to collections).
	This will usually be SSWDBObjectProxy or one of its subclasses"
	
	^objectProxyClass
]

{ #category : 'accessing' }
SSWReStore >> objectProxyClass: aClass [

	"objectProxyClass stores the class of Proxy to use for Objects (as opposed to collections).
	This will usually be SSWDBObjectProxy or one of its subclasses"
	
	objectProxyClass := aClass
]

{ #category : 'proxy manipulation' }
SSWReStore >> objectProxyClassFor: aClass [

	^aClass preferredObjectProxyClass ifNil: [self objectProxyClass]
]

{ #category : 'initialize/release' }
SSWReStore >> onStartup [

	self connection isNil ifFalse: [self connection onStartup].

	"Clear the statement cache of any active ReStores, 
	since these will reference the connection active in the previous session"
	self clearStatementCache
]

{ #category : 'connection' }
SSWReStore >> openConnection [

	"Open the receiver's connection to the database"

	[self connection connect] on: self dbErrorClass do:
		[ :exc |
		self connection free.
		exc pass].

	self connection willAutoCommit: false.
	self connection postConnect
]

{ #category : 'class maintenance' }
SSWReStore >> persistentSystemClasses [

	"Private - Return all ReStore system classes that exist in the database"

	^Array with: SSWDBTableRecord
]

{ #category : 'connection' }
SSWReStore >> postConnect [

	"Reinitializate the mutex"
	self transactionMutex: Mutex new.

	"Must reset system classes after login to use current dialect's name transformation strategy"
	self persistentSystemClasses do: [ :each | self addClass: each].

	self class activated: self
]

{ #category : 'connection' }
SSWReStore >> postDisconnect [

	self clearAllCaches.

	self class deactivated: self
]

{ #category : 'connection' }
SSWReStore >> preDisconnect [

	"Statements may need an active connection in order to be free'd correctly, so this is done pre-disconnect"

	self clearStatementCache
]

{ #category : 'connection' }
SSWReStore >> prepareStatementForQuery: anSSWSQLQuery [

	"Prepare (including column defs) and return a DBPreparedStatement for the given query"
	
	anSSWSQLQuery preExecIn: self.

	^self connection prepareQuery: anSSWSQLQuery
]

{ #category : 'proxy manipulation' }
SSWReStore >> proxy: anSSWDBProxy forwarded: aMessage [

	"anSSWDBProxy has just forwarded aMessage to its proxiedObject.
	Take any necessary actions here and forward to other interested parties"

	transaction == nil ifTrue: [self beginDumbTransaction].

	self transaction proxy: anSSWDBProxy forwarded: aMessage
]

{ #category : 'accessing' }
SSWReStore >> proxyCache [

	"proxyCache stores a Dictionary mapping classes of persistent objects 
	to a further dictionary mapping the unique IDs of persistent database objects
	to the proxy (SSWDBObjectProxy) which represents that object in the image.
	The sub-dictionary is weak-valued by default"
	
	^proxyCache
]

{ #category : 'accessing' }
SSWReStore >> proxyCache: aDictionary [

	"proxyCache stores a Dictionary mapping classes of persistent objects 
	to a further dictionary mapping the unique IDs of persistent database objects
	to the proxy (SSWDBObjectProxy) which represents that object in the image.
	The sub-dictionary is weak-valued by default"
	
	proxyCache := aDictionary
]

{ #category : 'accessing' }
SSWReStore >> readAllBatchSize [

	"When using the readAll function to mass-read components for all of a collection's elements, a parameteised statement is used with a fixed number of query parameters.
	This number should be a balance between the minimum and maximum likely collection size.
	 - query sets smaller than this are padded with nulls
	 - query sets larger than this are batched into sets of this size resulting in multiple queries (which readAll is designed to avoid) albeit (N/batchSize) ceiling queries rather than N.

	This value can be overridden in individual tables if required"

	^readAllBatchSize ifNil: [self defaultReadAllBatchSize]
]

{ #category : 'accessing' }
SSWReStore >> readAllBatchSize: anInteger [

	"When using the readAll function to mass-read components for all of a collection's elements, a parameteised statement is used with a fixed number of query parameters.
	This number should be a balance between the minimum and maximum likely collection size.
	 - query sets smaller than this are padded with nulls
	 - query sets larger than this are batched into sets of this size resulting in multiple queries (which readAll is designed to avoid) albeit (N/batchSize) ceiling queries rather than N.

	This value can be overridden in individual tables if required"

	readAllBatchSize := anInteger
]

{ #category : 'connection' }
SSWReStore >> reconnect [

	self isConnected ifTrue: [self disconnect].
	self connect
]

{ #category : 'read/write objects' }
SSWReStore >> recoverObjectOfClass: aClass withID: anID into: anSSWDBObjectProxy [

	"Optimised query for recovering objects into an unrecovered proxy.
	Uses cached prepared statement"
	
	| table statement row |

	table := self tableForClass: aClass.

	statement := table readStatement.
	statement values: (Array with: anID).
	statement exec.
	row := statement results first.
	statement close.

	row isNil 
		ifTrue: [anSSWDBObjectProxy _proxiedObjectMissing]
		ifFalse: [table recoverInstanceFromRow: row into: anSSWDBObjectProxy]
]

{ #category : 'transactionless api' }
SSWReStore >> refresh: anObject [

	"Refresh anObject according to its own strategy (e.g. always; only if changed; lazy)"

	self refreshAll: {anObject}
]

{ #category : 'transactionless api' }
SSWReStore >> refreshAll: aCollection [

	"Refresh all elements of aCollection according to their own strategy (e.g. always; only if changed; lazy)"

	self transactionCritical:
		[self ensureNoActiveTransaction.
		self connection rollbackTxn.

		"To give consistent behaviour we first rollback the objects. 
		This ensures that any current changes are undone regardless of whether the object refreshes itself only if updated, or always refreshes itself regardless"
		self _rollbackObjects: aCollection.

		aCollection do: [ :each | each _refreshIn: self]]
]

{ #category : 'transactionless api' }
SSWReStore >> refreshAllIfUpdated: aCollection [

	"Refresh those members of aCollection which have been updated in the database"
	
	self transactionCritical:
		[self ensureNoActiveTransaction.
		self connection rollbackTxn.

		"To give consistent behaviour we first rollback the objects. 
		This ensures that any current changes are undone regardless of whether the object is able to detect if it has been updated, or it has to refresh itself regardless"
		self _rollbackObjects: aCollection.

		aCollection do: [ :each | each _refreshIfUpdatedIn: self]]
]

{ #category : 'transaction api' }
SSWReStore >> refreshAllObjects [

	"Patched for issue 120-010 (revised)"

	self transactionCritical:
		[self ensureNoActiveTransaction.
		self connection rollbackTxn.

		self proxyCache keysAndValuesDo: 
			[ :class :proxies | 
			(self isSystemClass: class) ifFalse:
				[proxies do: 
					[ :each | 
					each _forgetProxiedObject.
					each _collectionProxies notNil ifTrue: 
						[each _collectionProxies do: [ :coll | coll _forgetProxiedObject]]]]]]
]

{ #category : 'transaction api' }
SSWReStore >> refreshAndRollforwardTransaction [

	self isTransactionInProgress ifFalse: [self error: 'No transaction in progress'].

	self transactionCritical: 
		[self connection rollbackTxn.
		self transaction refreshAndRollforward]
]

{ #category : 'class maintenance' }
SSWReStore >> refreshClasses [

	"Regenerate each table in the tableCache from its class"

	self tableCache copy keysDo: [ :class | self addClass: class]
]

{ #category : 'transactionless api' }
SSWReStore >> refreshIfUpdated: anObject [

	self refreshAllIfUpdated: {anObject}
]

{ #category : 'read/write objects' }
SSWReStore >> refreshProxyIfUpdated: anSSWDBObjectProxy [

	"Refresh the contents of anSSWDBObjectProxy if the version in the database has been updated
	since that held by anSSWDBObjectProxy was read.

	Return whether any change was detected & refreshed"
	
	| table statement row |

	table := self tableForClass: anSSWDBObjectProxy _class.

	statement := table refreshStatement.
	statement values: (Array with: anSSWDBObjectProxy _id).
	statement exec.
	row := statement results first.
	statement close.

	"A row will not be returned if the object has been deleted"
	row isNil ifTrue: 
		[anSSWDBObjectProxy _proxiedObjectMissing. 
		^true].

	^(table versionControlField lookupIn: row) ~= anSSWDBObjectProxy _version 
		ifTrue: [anSSWDBObjectProxy _forceRefresh. true] 
		ifFalse: [false]
]

{ #category : 'proxy manipulation' }
SSWReStore >> registerProxy: anSSWDBObjectProxy [

	self cacheObject: anSSWDBObjectProxy
]

{ #category : 'proxy manipulation' }
SSWReStore >> removeFromTransaction: aProxy [

	self transaction removeProxy: aProxy
]

{ #category : 'class maintenance' }
SSWReStore >> renameTable: oldTable to: newTable [

	"Private - Rename the old-named table to the new name, updating relevant objects"

	| instances |

	self sqlDialect renameTable: oldTable to: newTable in: self.

	"Also update the TableRecord in the DB"
	instances := (self instancesOf: SSWDBTableRecord) satisfying: [ :each | each tableName = oldTable name].
	self supportsFullTableRecords ifTrue: [instances modify: [ :each | each fullTableName: newTable fullName]].
	instances modify: [ :each | each tableName: newTable name].

	"Clear any cached TableRecord for the old table"
	(self nextIDCache detect: [ :each | each tableName = oldTable name] ifNone: [nil]) ifNotNil:
		[ :oldRecord || cachedOldTable |
		oldRecord tableName: newTable name.
		self supportsFullTableRecords ifTrue: [oldRecord fullTableName: newTable fullName].
		cachedOldTable := self nextIDCache keyAtValue: oldRecord.
		cachedOldTable isNil ifFalse: [self nextIDCache removeKey: cachedOldTable]].

	"Also rename containedTables"
	oldTable containedTables with: newTable containedTables do:
		[ :oldContainedTable :newContainedTable |
		self renameTable: oldContainedTable to: newContainedTable]
]

{ #category : 'class maintenance' }
SSWReStore >> renamedClass: aClass from: aSymbol [

	"Rename the table related to aClass to match its new name.
	Assumes standard table naming was used on the class"

	| newTable newDefinitionTable oldTable oldDefinitionTable instances |

	newTable := self addClass: aClass.
	newTable isRootTable ifFalse: 
		["Create and modify an instancesOf: collection for rows specifying the old class name"
		instances := (self instancesOf: newTable rootClass) satisfying: [ :e | e class = aSymbol asString].
		^instances modify: [ :each | each class: aClass]].

	newDefinitionTable := newTable forCreation.
	newDefinitionTable isNil ifTrue: [^self].

	oldTable := aClass tableIn: self.
	oldTable name: (self sqlDialect transformClassName: aSymbol).
	oldTable fullName: oldTable name.
	self validateTable: oldTable.
	oldTable containedTables do: [ :each | self validateTable: each].
	oldDefinitionTable := oldTable forCreation.

	[self evaluateAsTxn:
		[self renameTable: oldDefinitionTable to: newDefinitionTable.
		true]] 
			ensure: [self clearDBTableNames]
]

{ #category : 'class maintenance' }
SSWReStore >> renamedInstVar: newInstVar from: oldInstVar in: aClass [

	"Rename the column corresponding to oldInstVar (a Symbol) in aClass to match newInstVar.
	Assumes standard field naming was used on the class"

	| table definitionTable newField oldField columns |

	"Ensure the receiver is up-to-date with the definition of aClass"
	table := self addClass: aClass.

	"Check old iv field already exists and new iv field does not exist"
	newField := table fieldAccessing: newInstVar.
	oldField := table define: oldInstVar as: newField targetClass.
	columns := self columnsInTable: table.
	(columns anySatisfy: [ :col | col name asUppercase = oldField name asUppercase]) ifFalse:
		[(self error: 'No column corresponding to old inst var ', oldInstVar)].
	(columns anySatisfy: [ :col | col name asUppercase = newField name asUppercase]) ifTrue:
		[(self error: 'Already has column corresponding to new inst var ', newInstVar)].

	self evaluateInTxn: 
		[self sqlDialect renameField: oldField to: newField in: self.
		true].

	"Re-add the class to drop the oldField"
	self addClass: aClass.
	definitionTable := table rootTable forCreation.
	definitionTable == table ifFalse: [self addClassWithSubclasses: definitionTable instanceClass]
]

{ #category : 'class maintenance' }
SSWReStore >> resetClasses [

	self clearTableCache.

	"tableCache should always contain the required system classes"
	self persistentSystemClasses do: [ :each | self addClass: each]
]

{ #category : 'transactionless api' }
SSWReStore >> rollback: anObject [

	self rollbackAll: {anObject}
]

{ #category : 'transactionless api' }
SSWReStore >> rollbackAll: aCollection [

	"Rollback any changes made to the members of aCollection"

	self transactionCritical:
		[self ensureNoActiveTransaction.
		self _rollbackObjects: aCollection]
]

{ #category : 'transaction api' }
SSWReStore >> rollbackAndRefreshTransaction [

	self isTransactionInProgress ifFalse: [self error: 'No transaction in progress'].

	self transactionCritical:
		[self connection rollbackTxn.
		self transaction rollbackAndRefresh.
		self transaction: self transaction ownerTransaction]
]

{ #category : 'transaction api' }
SSWReStore >> rollbackTransaction [

	| rolledBack |

	self hasTransaction ifFalse: [self error: 'No transaction to rollback'].

	self transactionCritical:
		[rolledBack := self transaction rollback.
		self transaction: self transaction ownerTransaction.
		self connection rollbackTxn].

	rolledBack do: [ :each | each onRollback].

	"Implementation of onRollback may cause further objects to be referenced - where this has happened invoke a softRollback to ensure all persistent objects are proxies"
	self hasTransaction ifTrue: [self softRollback]
]

{ #category : 'querying' }
SSWReStore >> rowFromQuery: anSSWSQLQuery [

	"Return the sole/first row obtained by execuing anSSWSQLQuery"
	
	| results row |
		
	results := self executeQuery: anSSWSQLQuery.

	row := results first.
		
	results free.
	
	^row
]

{ #category : 'querying' }
SSWReStore >> rowsFromQuery: anSSWSQLQuery do: aBlock [

	| results |
		
	results := self executeQuery: anSSWSQLQuery.

	results 
		do: [ :row | aBlock value: row];
		free
]

{ #category : 'querying' }
SSWReStore >> rowsFromStatement: aDBPreparedStatement do: aBlock [

	aDBPreparedStatement exec.

	[aDBPreparedStatement results do: [ :row | aBlock value: row]] ensure: [aDBPreparedStatement close]
]

{ #category : 'querying' }
SSWReStore >> rowsFromStatement: aDBPreparedStatement keysAndValuesDo: aBlock [

	aDBPreparedStatement exec.

	[aDBPreparedStatement results keysAndValuesDo: [ :index :row | aBlock value: index value: row]] ensure: [aDBPreparedStatement close]
]

{ #category : 'transaction management' }
SSWReStore >> selectChanged: aCollection [

	"Return those elements of aCollection which have changed"

	^aCollection inject: IdentitySet new into: [ :all :each | all addAll: (each _changedObjectsIn: self)]
]

{ #category : 'initialize/release' }
SSWReStore >> setDefaultDebugMode [

	self isDebugging: SSWReStore isDebugging
]

{ #category : 'initialize/release' }
SSWReStore >> setDefaultTransactionMode [

	self useTransactionsWithVersioning
]

{ #category : 'connection' }
SSWReStore >> softDisconnect [

	"Disconnect from the DB but do not clear the proxy cache"

	self clearTxn.
	self connection close.
]

{ #category : 'transaction api' }
SSWReStore >> softRollback [

	"Carry out a 'soft rollback'. Note this is different from rollbackTransaction:

	The expectation is that there is no active transaction (hence no 'Transaction' postfix to the method name), just views onto some persistent objects which have been 'touched', i.e. swapped with their proxy such that all normal references point to the real object.
	Where an object has been touched it is not transparently updated if its database row is encountered, even where the row contains a later change. 
	Rollback these touches so that those objects *are* updated if their database rows are encountered. 

	Note this does not rollback any changes to these objects - this is the 'soft' part"

	self hasTransaction ifFalse: 
		["Just ensure we have an up-to-date view of the database"
		^self connection rollbackTxn].

	self transaction isDumb 
		ifTrue: [self rollbackTransaction]
		ifFalse: [self error: 'active transaction - cannot proceed']

]

{ #category : 'accessing' }
SSWReStore >> sqlDialect [

	^self connection sqlDialect
]

{ #category : 'accessing' }
SSWReStore >> supportsFullTableRecords [

	"supportsFullTableRecords stores a Boolean indicating whether the receiver
	is using the full definition of SSWDBTableRecord including description and fullTableName.
	This is necessary to automatically support long (> db limit) table names.

	Note this is false (off) by default in ReStore 1.20 to ensure compatibility with earlier releases.
	The default may become true (on) in a future release"

	supportsFullTableRecords isNil ifTrue: [supportsFullTableRecords := false].

	^supportsFullTableRecords
]

{ #category : 'accessing' }
SSWReStore >> supportsFullTableRecords: aBoolean [

	"supportsFullTableRecords stores a Boolean indicating whether the receiver
	is using the full definition of SSWDBTableRecord including description and fullTableName.
	This is necessary to automatically support long (> db limit) table names.

	Note this is false (off) by default in ReStore 1.20 to ensure compatibility with earlier releases.
	The default may become true (on) in a future release"

	supportsFullTableRecords := aBoolean
]

{ #category : 'testing' }
SSWReStore >> supportsVersioning [

	^self objectProxyClass = SSWDBVersionedCachingObjectProxy
]

{ #category : 'class maintenance' }
SSWReStore >> synchronizeAllClasses [

	"Synchronize the definitions of all the tables associated with the receiver's classes"

	[self evaluateAsTxn:
		[self persistentSystemClasses do: 
			[ :each |
			(self tableForClass: each) synchronizeDefinition].

		self tableCache keysAndValuesDo: 
			[ :class :table | 
			(self isSystemClass: class) ifFalse: [table synchronizeDefinition]].

		true]] 
			ensure: [self clearDBTableNames]
]

{ #category : 'class maintenance' }
SSWReStore >> synchronizeClass: aClass [

	"Synchronize the definition(s) of the table(s) associated with the given class"

	[self evaluateAsTxn:
		[self persistentSystemClasses do: 
			[ :each |
			(self tableForClass: each) synchronizeDefinition].

		(self tableForClass: aClass) synchronizeDefinition.

		true]] 
			ensure: [self clearDBTableNames]
]

{ #category : 'accessing' }
SSWReStore >> tableCache [

	"tableCache stores a Dictionary mapping classes (known as persistent to the receiver)
	to their equivalent SSWDBTable"
	
	^tableCache
]

{ #category : 'accessing' }
SSWReStore >> tableCache: anIdentityDictionary [

	"tableCache stores a Dictionary mapping classes (known as persistent to the receiver)
	to their equivalent SSWDBTable"
	
	tableCache := anIdentityDictionary
]

{ #category : 'cache management' }
SSWReStore >> tableForClass: aClass [

	^self tableForClass: aClass ifAbsent: [self addClass: aClass]
]

{ #category : 'cache management' }
SSWReStore >> tableForClass: aClass ifAbsent: aBlock [
	
	^self tableCache at: aClass ifAbsent: aBlock
]

{ #category : 'cache management' }
SSWReStore >> tableRecordFor: aDBTable [

	^self nextIDCache at: aDBTable ifAbsentPut: [(self instancesOf: SSWDBTableRecord) detect: [ :seq | seq tableName = aDBTable name] ifNone: [self error: 'nextID not found for table ', aDBTable name]]
]

{ #category : 'accessing' }
SSWReStore >> transaction [

	"transaction stores an SSWDBTransaction which manages 
	the writing/rollback of object changes within this ReStore"
	
	^transaction
]

{ #category : 'accessing' }
SSWReStore >> transaction: anSSWDBTransaction [

	"transaction stores an SSWDBTransaction which manages 
	the writing/rollback of object changes within this ReStore"
	
	transaction := anSSWDBTransaction
]

{ #category : 'accessing' }
SSWReStore >> transactionClass [

	"transactionClass stores the class of transaction (SSWDBTransaction subclass) 
	which the receiver uses"
	
	^transactionClass
]

{ #category : 'accessing' }
SSWReStore >> transactionClass: aSSWDBTransactionSubclass [

	"transactionClass stores the class of transaction (SSWDBTransaction subclass) 
	which the receiver uses"
	
	self isTransactionInProgress ifTrue: [self error: 'Cannot change transactionClass whilst transaction in progress'].
	
	transactionClass := aSSWDBTransactionSubclass
]

{ #category : 'transaction api' }
SSWReStore >> transactionCommitFailures [

	self isTransactionInProgress ifFalse: [self error: 'No transaction in progress'].
	
	^self transaction hasFailedCommit
		ifTrue: [self transaction commitFailures]
		ifFalse: [self error: 'Transaction has not failed commit']
]

{ #category : 'transaction management' }
SSWReStore >> transactionCritical: aBlock [

	"Evaluate aBlock under the guard of the transactionMutex"

	self isDebugging ifFalse: [^self transactionMutex critical: aBlock].

	^self transactionMutex critical: aBlock ifLocked: 
		[Processor activeProcess isInIDECallStack
			ifTrue: [aBlock value]
			ifFalse: [self transactionMutex critical: aBlock]]
]

{ #category : 'transaction management' }
SSWReStore >> transactionCritical: aBlock ifLocked: lockedBlock [

	"Evaluate aBlock under the guard of the transactionMutex"

	^self transactionMutex critical: aBlock ifLocked: lockedBlock
]

{ #category : 'accessing' }
SSWReStore >> transactionMutex [

	"transactionMutex holds a Mutex which guards access to critical areas of transaction functionality.
	This prevents transactions being corrupted by access to objects during commit/rollback"

	^transactionMutex
]

{ #category : 'accessing' }
SSWReStore >> transactionMutex: aMutex [

	"transactionMutex holds a Mutex which guards access to critical areas of transaction functionality.
	This prevents transactions being corrupted by access to objects during commit/rollback"

	transactionMutex := aMutex
]

{ #category : 'initialize/release' }
SSWReStore >> translateMessage: aSymbol toFunction: aSQLFunction [

	"Add aSymbol>>aSQLFunction as an additional message>>function translation"

	self isConnected ifFalse: [self error: 'connect before adding functions'].

	self sqlDialect translateMessage: aSymbol toFunction: aSQLFunction
]

{ #category : 'cache management' }
SSWReStore >> uncacheObject: aPersistentObjectProxy [

	"Remove the given persistent object proxy to the receiver's cache"

	"Use _class to avoid fetching inherited objects (issue#0015)"
	(self classCacheFor: aPersistentObjectProxy _class) removeKey: aPersistentObjectProxy _id
]

{ #category : 'class maintenance' }
SSWReStore >> unstoreNextIDsForTables: aCollection [

	"Forget and unstore the NEXT_ID entries for aCollection of (dropped) SSWDBTables"

	| droppedNames |

	aCollection do: [ :table | self nextIDCache removeKey: table ifAbsent: []].
	(self dbIncludesTableForClass: SSWDBTableRecord) ifFalse: [^self].

	droppedNames := (aCollection collect: [ :e | e name]) asArray.

	((self instancesOf: SSWDBTableRecord) satisfying: [ :nextID | droppedNames includes: nextID tableName]) unstoreAll
]

{ #category : 'initialize/release' }
SSWReStore >> useTransactionsWithVersioning [

	"Set the receiver to use (single) transactions with version counting
	 - for optimistic-locking, multi-user, transaction controlled DB updating"

	self
		ensureCanChangeTransactionMode;
		transactionClass: SSWDBSingleTransactionWithVersioning;
		objectProxyClass: SSWDBVersionedCachingObjectProxy.

	self isConnected ifTrue: [self refreshClasses]

]

{ #category : 'initialize/release' }
SSWReStore >> useTransactionsWithoutVersioning [

	"Set the receiver to use (single) transactions *without* version counting
	 - for single-user, transaction controlled DB updating"

	self 	
		ensureCanChangeTransactionMode;
		transactionClass: SSWDBSingleTransaction;
		objectProxyClass: SSWDBCachingObjectProxy;
		refreshClasses

]

{ #category : 'class maintenance' }
SSWReStore >> validateTable: anSSWDBTable [

	"Private - At present, validation just checks that the table name is within the permitted size,
	and substitutes a unique abbreviated name if not"

	anSSWDBTable name size > self sqlDialect maxTableNameLength ifTrue:
		[self supportsFullTableRecords
		ifTrue:
			[| abbrevName |
			anSSWDBTable isRootTable 
			ifTrue:
				[| record |
				record := self fullTableRecordFor: anSSWDBTable.
				record isNil
					ifTrue: [abbrevName := self nextShortTableNameFor: anSSWDBTable]
					ifFalse: [abbrevName := record tableName]]
			ifFalse:
				[abbrevName := anSSWDBTable rootTable name].

			anSSWDBTable name: abbrevName]
		ifFalse:
			[self error: 'Oversize table name. Enable full table records (see supportsFullTableRecords)']]
]
