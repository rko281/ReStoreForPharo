"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBTable,
	#superclass : #SSWSQLTable,
	#instVars : [
		'instanceClass',
		'fullName',
		'idField',
		'idDataField',
		'dataFields',
		'controlFields',
		'collectionSpecs',
		'abbreviations',
		'reStore',
		'insertStatement',
		'readStatement',
		'refreshStatement',
		'deleteStatement',
		'readAllBatchSize'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWDBTable class >> forClass: aClass [

	^self new
		instanceClass: aClass;
		yourself
]

{ #category : #'instance creation' }
SSWDBTable class >> forClass: aClass in: anSSWReStore [

	^(self forClass: aClass)
		initializeIn: anSSWReStore;
		yourself
]

{ #category : #'instance creation' }
SSWDBTable class >> new [

	^super new
		dataFields: SSWSQLFieldCollection new;
		controlFields: SSWSQLFieldCollection new;
		collectionSpecs: OrderedCollection new;
		abbreviations: Dictionary new;
		yourself
]

{ #category : #defining }
SSWDBTable >> abbreviate: aSymbol to: abbrevSymbol [

	"Define abbrevSymbol as an abbreviated name for the inst var named aSymbol"

	self abbreviations at: aSymbol put: abbrevSymbol
]

{ #category : #accessing }
SSWDBTable >> abbreviations [

	"abbreviations stores a Dictionary mapping instance variables (Symbols)
	to abbreviated names (Symbols) to use to define their database name.

	This is required where names exceed the DB size limit"

	^abbreviations
]

{ #category : #accessing }
SSWDBTable >> abbreviations: aDictionary [

	"abbreviations stores a Dictionary mapping instance variables (Symbols)
	to abbreviated names (Symbols) to use to define their database name.

	This is required where names exceed the DB size limit"

	abbreviations := aDictionary
]

{ #category : #evaluating }
SSWDBTable >> aboutToBeUnstored: anObject [

	"anObject (which originated in the receiver table) is about to be removed from the DB.
	Notify the receiver's components so they can take any necessary action"

	self componentsDo: [ :field | field aboutToBeUnstored: anObject]
]

{ #category : #defining }
SSWDBTable >> addDataField: anSSWDBField [

	anSSWDBField table: self.
	^self dataFields add: anSSWDBField
]

{ #category : #enumerating }
SSWDBTable >> allDataFieldsDo: aBlock [

	"Include the ID field if it is a data field"
	
	self idDataField ifNotNil: [ :field | aBlock value: field].

	self dataFields do: aBlock

]

{ #category : #evaluating }
SSWDBTable >> allFields [

	"Return an SSWSQLFieldCollection of all the receiver's fields"
	
	^self dataAndControlFields
		addFirst: self idField;
		yourself
]

{ #category : #enumerating }
SSWDBTable >> allFieldsDetect: aBlock ifNone: noneBlock [

	(aBlock value: self idField) ifTrue: [^self idField].

	^self dataFields detect: aBlock ifNone: [self controlFields detect: aBlock ifNone: noneBlock]
]

{ #category : #enumerating }
SSWDBTable >> allFieldsDo: aBlock [

	"Faster than allFields do:"
	
	aBlock value: self idField.
	self dataFields do: aBlock.
	self controlFields do: aBlock

]

{ #category : #evaluating }
SSWDBTable >> collectionAccessing: aSymbol [

	"Determine and return the collectionSpec of the receiver which accesses the inst var named aSymbol
	of the receiver's instanceClass"
	
	^self collectionSpecs detect: [ :spec | spec accessor accesses: aSymbol] ifNone: [nil]
]

{ #category : #accessing }
SSWDBTable >> collectionSpecs [

	"collectionSpecs stores a Collection of SSWDBCollectionSpecs which define the persistent
	collections held by instances of the receiver's instanceClass"
	
	^collectionSpecs
]

{ #category : #accessing }
SSWDBTable >> collectionSpecs: anOrderedCollection [

	"collectionSpecs stores a Collection of SSWDBCollectionSpecs which define the persistent
	collections held by instances of the receiver's instanceClass"
	
	collectionSpecs := anOrderedCollection
]

{ #category : #evaluating }
SSWDBTable >> componentAccessing: aSymbol [

	^(self fieldAccessing: aSymbol) ifNil: [self collectionAccessing: aSymbol]
]

{ #category : #enumerating }
SSWDBTable >> componentsDo: aBlock [

	"Evaluate aBlock with each component (field or collection spec) of the receiver"
	
	self dataFields do: aBlock.
	self collectionSpecs do: aBlock
]

{ #category : #enumerating }
SSWDBTable >> componentsSelect: aBlock [

	| selected |

	selected := OrderedCollection new.
	self componentsDo: [ :each | (aBlock value: each) ifTrue: [selected add: each]].

	^selected
]

{ #category : #evaluating }
SSWDBTable >> containedTableNameRoot [

	"Return the String to use as the root of all containedTables owned by the receiver"
	
	"Use a double-underscore to avoid name clashes with any class tables.
	ASSERT: class names NEVER contain an underscore"
	^self fullName, '__'
]

{ #category : #evaluating }
SSWDBTable >> containedTables [

	"At present, only collection specs can contain other tables"

	| containedTables |

	containedTables := OrderedCollection new.

	self collectionSpecs do: [ :spec | containedTables addAll: spec containedTables].

	^containedTables
]

{ #category : #accessing }
SSWDBTable >> controlFields [

	"controlFields stores a Collection of SSWDBFields that do not hold data,
	but provide assistance to the ReStore persistency mechanism.

	Exact content and behaviour is dependent on the receiver's clients,
	but e.g. could refer to 'isActive', 'shouldIgnore' flags"	

	^controlFields
]

{ #category : #accessing }
SSWDBTable >> controlFields: aCollection [

	"controlFields stores a Collection of SSWDBFields that do not hold data,
	but provide assistance to the ReStore persistency mechanism.

	Exact content and behaviour is dependent on the receiver's clients,
	but e.g. could refer to 'isActive', 'shouldIgnore' flags"

	controlFields := aCollection
]

{ #category : #defining }
SSWDBTable >> copyForProxy: anObject [

	| copy |

	copy := anObject shallowCopy.

	self dataFields do: [ :each | each accessor copyValueIn: anObject to: copy].

	^copy
]

{ #category : #'db maintenance' }
SSWDBTable >> createDefinition [

	"Create a table based on the receiver in the database accessed by the receiver's reStore.
	ASSERT: the receiver does not exist as a table in the database"
	
	self reStore
		executeSQL: self sqlDefinition;
		createTableRecordFor: self
	
]

{ #category : #'initialize/release' }
SSWDBTable >> createIDField [

	"Define the receiver table's unique ID field - it is not named at this point"
	
	| field |
	
	field := SSWDBStaticField new.
	
	field
		table: self;
		accessor: SSWDBIDAccessor new;
		targetClass: Integer.
	
	self idField: field
]

{ #category : #'instance creation' }
SSWDBTable >> createInstanceFromRow: aDBRow [

	| object id |
	
	object := self instanceClass basicNew.
	id := aDBRow atField: self idField ifAbsent: [nil].

	self allDataFieldsDo:
		[ :field |
		field applyValueFromRow: aDBRow to: object].
	
	self collectionSpecs do:
		[ :collection |
		collection applyTo: object withID: id in: self reStore].
	
	^object
]

{ #category : #'instance creation' }
SSWDBTable >> createNonProxiedInstanceFromRow: aDBRow [
	
	"For internal/special non-proxied persistent objects"

	| instance |
	
	instance := self createInstanceFromRow: aDBRow.

	self controlFields do:
		[ :field |
		field applyValueFromRow: aDBRow to: instance].

	^instance
]

{ #category : #evaluating }
SSWDBTable >> dataAndControlFields [

	^(SSWSQLFieldCollection new: 24)
		addAll: self dataFields;
		addAll: self controlFields;
		yourself

]

{ #category : #accessing }
SSWDBTable >> dataFields [

	"dataFields stores an SSWSQLFieldCollection of SSWDBFields that define the data held by this table. 
	This specifically excludes the unique ID field and any control fields, which are held separately"
	
	^dataFields
]

{ #category : #accessing }
SSWDBTable >> dataFields: anSSWSQLFieldCollection [

	"dataFields stores an SSWSQLFieldCollection of SSWDBFields that define the data held by this table. 
	This specifically excludes the unique ID field and any control fields, which are held separately"
	
	dataFields := anSSWSQLFieldCollection
]

{ #category : #evaluating }
SSWDBTable >> dbNameFor: aSymbol [

	"Return the name (String) to use within the database for the inst var named aSymbol"

	^self sqlDialect transformInstVarName: (self symbolicNameFor: aSymbol)
]

{ #category : #evaluating }
SSWDBTable >> defaultName [

	"The default (table)name is the name of the receiver's instanceClass,
	transformed according to the sqlDialect"
	
	^self sqlDialect transformClassName: self instanceClass name

]

{ #category : #defining }
SSWDBTable >> define: aSymbol abbreviation: abbrevSymbol as: anObject [

	"Definition method for abbreviations. 
	As such, only suitable for definitions of instance variables"

	^self 
		abbreviate: aSymbol to: abbrevSymbol;
		define: aSymbol as: anObject
]

{ #category : #defining }
SSWDBTable >> define: aSymbol as: anObject [

	"General user method for table specification.	 
	anObject could be a Class or ClassWithInfo (defining a field) or a CollectionSpec (defining a Collection).
	Example usage of each type:
		define: #name as: String;	
		define: #children as: (Collection of: Person owner: #parent)
	Return the table component added to the receiver"

	"Double-despatch; the object knows how to define itself"
	^anObject defineAs: aSymbol in: self
]

{ #category : #defining }
SSWDBTable >> define: aSymbol asCollectionSpec: aCollectionSpec [

	^self collectionSpecs add:
		(aCollectionSpec
			accessor: (SSWInstVarAccessor toAccess: aSymbol in: self instanceClass);
			table: self;
			yourself)
]

{ #category : #defining }
SSWDBTable >> define: aSymbol asFieldNamed: aString holding: aClass [

	"Return the field created"

	aString size > self sqlDialect maxColumnNameLength ifTrue: 
		[self error: ('Column <1s> for <2s> is larger than max length of <3d>. Define a suitable abbreviation'
					expandMacrosWith: aString with: aSymbol with: self sqlDialect maxColumnNameLength)].
	
	^self addDataField:
		(SSWDBStaticField new
			name: aString;
			targetClass: aClass;
			accessor: ((self sqlDialect instVarAccessorFor: aClass) access: aSymbol in: self instanceClass);
			yourself)
]

{ #category : #defining }
SSWDBTable >> define: aSymbol asInstVarHolding: aClass [

	"Return the field created"
	
	^aClass shouldInlinePersistency
		ifTrue: [self define: aSymbol asInstVarHoldingInlined: aClass]
		ifFalse: [self define: aSymbol asFieldNamed: (self dbNameFor: aSymbol) holding: aClass]
]

{ #category : #defining }
SSWDBTable >> define: aSymbol asInstVarHoldingInlined: aClass [

	| inliner |

	inliner := SSWFieldInliner new.
	inliner 
		table: self;
		instanceClass: self instanceClass;
		inlinedName: aSymbol;
		inlinedSlot: (self instanceClass allInstVarNames indexOf: aSymbol asString);
		inlinedClass: aClass.

	inliner inlinedSlot < 1 ifTrue: [self error: ('Undefined instance variable ', aSymbol)].

	aClass reStoreDefinition addDefinitionToTable: inliner.

	"To satisfy protocol of returning field created"
	^inliner fields first
]

{ #category : #defining }
SSWDBTable >> defineAsID: aSymbol [

	"Define the receiver's idField to access inst var aSymbol.
	Use of this method enables persistent objects to store their unique ID within themselves.
	This can be useful in some cases, although the unique ID is really internal information.
	Return the idField"
	
	^self defineAsID: aSymbol fieldName: (self dbNameFor: aSymbol)
]

{ #category : #defining }
SSWDBTable >> defineAsID: aSymbol fieldName: aString [

	"Define the receiver's idField to be named aString and to access inst var aSymbol.
	Use of this method enables persistent objects to store their unique ID within themselves.
	This can be useful in some cases, although the unique ID is really internal information.
	Return the idField"

	| field instanceAccessor |

	field := self defineIDFieldName: aString.
	instanceAccessor := SSWInstVarAccessor toAccess: aSymbol in: self instanceClass.

	field accessor instanceAccessor: instanceAccessor.

	self idDataField:
		(field copy
			accessor: instanceAccessor;
			yourself).

	^field
]

{ #category : #defining }
SSWDBTable >> defineDefaultIDField [

	"Define the default-named ID field.
	Return the field defined"
	
	self createIDField.

	^self idField 
		name: (self sqlDialect transformInstVarName: self idField accessor nameInDB);
		yourself
]

{ #category : #defining }
SSWDBTable >> defineIDFieldName: aString [

	"Define the receiver table's unique ID field to be named aString.
	Clients do not need to call this method if they are happy with the default name (based on #id_).
	Return the field created"

	self createIDField.

	^self idField 
		name: aString;
		yourself

]

{ #category : #testing }
SSWDBTable >> definesName: aString [

	^self name = aString or: [self containedTables anySatisfy: [ :each | each definesName: aString]]
]

{ #category : #accessing }
SSWDBTable >> deleteStatementGeneratedFrom: aDeleteQuery [

	^deleteStatement ifNil: [deleteStatement := self reStore prepareStatementForQuery: aDeleteQuery]
]

{ #category : #accessing }
SSWDBTable >> dependentComponents [

	^self componentsSelect: [ :each | each isDependent]
]

{ #category : #evaluating }
SSWDBTable >> dependentDataFields [
	
	^self dataFields select: [ :field | field isDependent]
]

{ #category : #evaluating }
SSWDBTable >> dependentDataFieldsSelect: aBlock [

	"Evaluate aBlock with each dependent component which is a data field, collecting those which answer true.
	Faster than dependentDataFields select:"
	
	^self dataFields select: [ :field | field isDependent and: [aBlock value: field]]
]

{ #category : #evaluating }
SSWDBTable >> fieldAccessing: aSymbol [

	"Determine and return the field of the receiver which accesses the inst var named aSymbol of the receiver's instanceClass"
	
	^self allFieldsDetect: [ :field | field accessor accesses: aSymbol] ifNone: [nil]
]

{ #category : #evaluating }
SSWDBTable >> fieldNamed: aString [

	^self allFieldsDetect: [ :field | field name = aString] ifNone: [nil]
]

{ #category : #evaluating }
SSWDBTable >> fieldsAccessing: aSymbol [

	| matching |

	matching := OrderedCollection new.

	self allFieldsDo: [ :field | (field accessor accesses: aSymbol) ifTrue: [matching add: field]].

	^matching
]

{ #category : #evaluating }
SSWDBTable >> forCreation [

	"Return an appropriate SSWDBxxxTable with which to 
	CREATE the receiver table in the database.
	
	Default - return the receiver"
	
	^self
]

{ #category : #'initialize/release' }
SSWDBTable >> freePreparedStatements [

	insertStatement notNil ifTrue: [insertStatement free].
	readStatement notNil ifTrue: [readStatement free].
	refreshStatement notNil ifTrue: [refreshStatement free].
	deleteStatement notNil ifTrue: [deleteStatement free].

	insertStatement := nil.
	readStatement := nil.
	refreshStatement := nil.
	deleteStatement := nil.

	self collectionSpecs do: [ :each | each freePreparedStatements].
]

{ #category : #accessing }
SSWDBTable >> fullName [

	"fullName stores the 'full' name of the receiver. 
	This is usually the same as the name, except where it exceeds the DB size limit,
	in which case name holds a suitably-abbreviated name, whilst fullName maintains the original"

	fullName isNil ifTrue: [fullName := self name].

	^fullName
]

{ #category : #accessing }
SSWDBTable >> fullName: aString [

	"fullName stores the 'full' name of the receiver. 
	This is usually the same as the name, except where it exceeds the DB size limit,
	in which case name holds a suitably-abbreviated name, whilst fullName maintains the original"

	fullName := aString
]

{ #category : #testing }
SSWDBTable >> hasCollectionAccessing: aSymbol [

	"Return a Boolean indicating whether the receiver has a collectionSpec
	accessing the instance variable name aSymbol"

	^(self collectionAccessing: aSymbol) ~= nil 
]

{ #category : #testing }
SSWDBTable >> hasFieldAccessing: aSymbol [

	"Return a Boolean indicating whether the receiver has a Field
	accessing the instance variable name aSymbol"

	^(self fieldAccessing: aSymbol) notNil 
]

{ #category : #accessing }
SSWDBTable >> idDataField [

	"idDataField stores a field which accesses the ID of instances when held as data in an actual object.
	This differs from the idField which accesses the ID solely in the proxy.
	Can be (and usually is) nil"

	^idDataField
]

{ #category : #accessing }
SSWDBTable >> idDataField: anObject [

	"idDataField stores a field which accesses the ID of instances when held as data in an actual object.
	This differs from the idField which accesses the ID solely in the proxy.
	Can be (and usually is) nil"

	idDataField := anObject
]

{ #category : #accessing }
SSWDBTable >> idField [

	"idField stores the SSWDBField which holds the unique ID of records in this table.	
	Lazy-defaulted if not set explicity"
	
	idField isNil ifTrue: [self defineDefaultIDField].
	
	^idField
]

{ #category : #accessing }
SSWDBTable >> idField: anSSWDBField [

	"idField stores the SSWDBField which holds the unique ID of records in this table"
	
	idField := anSSWDBField
]

{ #category : #'initialize/release' }
SSWDBTable >> initializeIn: anSSWReStore [

	self reStore: anSSWReStore.

	self controlFields: (anSSWReStore objectProxyClassFor: self instanceClass) controlFields.
	self controlFields do: 
		[ :field | 
		field table: self.
		field name: (self sqlDialect transformInstVarName: field accessor nameInDB)]
]

{ #category : #accessing }
SSWDBTable >> insertStatementGeneratedFrom: anInsertQuery [

	^insertStatement ifNil: [insertStatement := self reStore prepareStatementForQuery: anInsertQuery]
]

{ #category : #accessing }
SSWDBTable >> instanceClass [

	"instanceClass stores the Class which is equivalent to this table"
	
	^instanceClass
]

{ #category : #accessing }
SSWDBTable >> instanceClass: aClass [

	"instanceClass stores the Class which is equivalent to this table"
	
	"CHECK HERE: never allow aClass whose name includes an _
	as this can cause problems for the contained table mechanism"
	(aClass name includes: $_) ifTrue: [self error: 'Cannot use a Class name containing an underscore ( _ )'].

	instanceClass := aClass
]

{ #category : #'instance creation' }
SSWDBTable >> instanceClassFromRow: aDBRow [

	"Private - for the receiver this is always its static instance class"

	^self instanceClass
]

{ #category : #testing }
SSWDBTable >> isDefined [

	"Return a Boolean indicating if the receiver table is 'defined'
	i.e. if it has some meaningful fields/collections"
	
	^self dataFields size > 0 or: [self collectionSpecs size > 0]
]

{ #category : #testing }
SSWDBTable >> isRootTable [

	^true
]

{ #category : #testing }
SSWDBTable >> isValidForPersistence [

	"Tables are not persisted directly (e.g. via storeIn:), therefore consider them already persistent"

	^true
]

{ #category : #accessing }
SSWDBTable >> name [

	"Overriden to lazy initialize to default name"
	
	name isNil ifTrue: [name := fullName := self defaultName].
	
	^name
]

{ #category : #'instance creation' }
SSWDBTable >> nonPersistentCopyOf: anObject [

	"Return a non-persistent copy of the given object (which is of the receiver's instanceClass).
	Note that persistent collections are also copied"

	| copyObject |

	copyObject := anObject shallowCopy.

	self collectionSpecs do: 
		[ :spec |
		spec value: (spec value: anObject) copy in: copyObject].

	^copyObject
]

{ #category : #evaluating }
SSWDBTable >> parameterisedRecoveryQuery [

	"Return a parameterised SQLSelectQuery which can fetch a single row of this table by its ID"

	^SSWSQLSelectQuery new
		table: self withAllFields;
		conditions: (SSWSQLCondition field: self idField equalTo: SSWSQLQueryParameter);
		yourself
]

{ #category : #evaluating }
SSWDBTable >> parameterisedRefreshQuery [

	"Return a parameterised SQLSelectQuery which can be used to detect a change to a single row of this table based on its ID and version"

	^self parameterisedRecoveryQuery
		fields: (SSWSQLFieldCollection with: self versionControlField);
		yourself
]

{ #category : #accessing }
SSWDBTable >> reStore [

	"the SSWReStore to which this table belongs"

	^reStore
]

{ #category : #accessing }
SSWDBTable >> reStore: anSSWReStore [

	"the SSWReStore to which this table belongs"

	reStore := anSSWReStore
]

{ #category : #accessing }
SSWDBTable >> readAllBatchSize [

	"When using the readAll function to mass-read components of the receiver, a parameteised statement is used with a fixed number of query parameters.
	This number should be a balance between the minimum and maximum likely query set size for this table:
	 - query sets smaller than this are padded with nulls
	 - query sets larger than this are batched into sets of this size resulting in multiple queries (which readAll is designed to avoid) albeit (N/batchSize) ceiling queries rather than N"

	^readAllBatchSize ifNil: [self reStore readAllBatchSize]
]

{ #category : #accessing }
SSWDBTable >> readAllBatchSize: anInteger [

	"When using the readAll function to mass-read components of the receiver, a parameteised statement is used with a fixed number of query parameters.
	This number should be a balance between the minimum and maximum likely query set size for this table:
	 - query sets smaller than this are padded with nulls
	 - query sets larger than this are batched into sets of this size resulting in multiple queries (which readAll is designed to avoid) albeit (N/batchSize) ceiling queries rather than N"

	readAllBatchSize := anInteger
]

{ #category : #accessing }
SSWDBTable >> readStatement [

	^readStatement ifNil: [readStatement := self reStore prepareStatementForQuery: self parameterisedRecoveryQuery]
]

{ #category : #'instance creation' }
SSWDBTable >> recoverInstanceFromRow: aDBRow into: anSSWDBObjectProxy [
	
	anSSWDBObjectProxy 
		_proxiedObject: (self createInstanceFromRow: aDBRow);
		_aquireCollectionProxiesUsing: self collectionSpecs.

	self controlFields do:
		[ :field |
		field applyValueFromRow: aDBRow to: anSSWDBObjectProxy]
]

{ #category : #'instance creation' }
SSWDBTable >> refreshProxy: aProxy fromRow: aDBRow [

	| instance |

	instance := aProxy _proxiedObject.

	self dataFields do:
		[ :field |
		field applyValueFromRow: aDBRow to: instance].
	
	self controlFields do:
		[ :field |
		field applyValueFromRow: aDBRow to: aProxy]
]

{ #category : #'instance creation' }
SSWDBTable >> refreshProxy: aProxy whereChangedFromRow: aDBRow [

	"Return whether the proxy was refreshed at all"

	| instance changes |

	instance := aProxy _proxiedObject.

	changes := self dataFields select:
		[ :field |
		field applyValueIfChangedFromRow: aDBRow to: instance].
	
	changes addAll: (self controlFields select:
		[ :field |
		field applyValueIfChangedFromRow: aDBRow to: aProxy]).

	^changes isEmpty not
]

{ #category : #accessing }
SSWDBTable >> refreshStatement [

	^refreshStatement ifNil: [refreshStatement := self reStore prepareStatementForQuery: self parameterisedRefreshQuery]
]

{ #category : #evaluating }
SSWDBTable >> registerClass [

	"Return the class under which objects created from this table 
	should be registered in an SSWReStore's proxy cache.
	Normally this is their own class. Subclassed may change this"

	^self instanceClass
]

{ #category : #accessing }
SSWDBTable >> relatedComponents [

	^self componentsSelect: [ :each | each isRelated]
]

{ #category : #'db maintenance' }
SSWDBTable >> removeDefinition [

	"Remove the receiver's definition from the database accessed by the receiver's reStore.
	Return a collection of the dropped tables"

	| creationTable containedTables |

	creationTable := self forCreation.
	creationTable isNil ifTrue: [^#()].

	(self reStore dbIncludesTableNamed: creationTable name) ifTrue: 
		[self reStore executeSQL: ('DROP TABLE ', (self sqlDialect asIdentifier: creationTable name))].

	containedTables := creationTable containedTables.
	containedTables do: [ :containedTable | containedTable removeDefinition].

	^(OrderedCollection with: creationTable)
		addAll: containedTables;
		yourself
]

{ #category : #'db maintenance' }
SSWDBTable >> removeRedundantContainedTables [

	"Remove from the database accessed by the receiver's reStore 
	any contained tables that are no longer contained in the receiver"

	| root containedTableNames |

	root := self containedTableNameRoot.
	containedTableNames := self reStore dbTableNames select: [ :each | each beginsWith: root].

	"Don't delete any used containedTables"
	self containedTables do: [ :table | containedTableNames remove: table name ifAbsent: []].

	containedTableNames do:
		[ :tableName |
		self reStore executeSQL: ('DROP TABLE ', tableName)]
]

{ #category : #evaluating }
SSWDBTable >> rootClass [

	"Return the class which is the root of the receiver's persistent hierarchy.
	Standard definition - the receiver's instanceClass"

	^self instanceClass
]

{ #category : #evaluating }
SSWDBTable >> rootTable [

	"Return the table which is the root of the receiver's persistent hierarchy.
	Standard definition - the receiver"

	^self
]

{ #category : #output }
SSWDBTable >> sqlDefinition [

	| stream |
	
	stream := self sqlDialect sqlWriteStream.
	
	self writeSQLDefinitionOn: stream.
	
	^stream contents
]

{ #category : #evaluating }
SSWDBTable >> sqlDialect [

	^self reStore sqlDialect

]

{ #category : #evaluating }
SSWDBTable >> staticConditions [

	"Return an SSWSQLConditionCollection which is always applied
	when SELECTing from the receiver table.
	Unlike conditions that may be derived from controlFields, these conditions
	do not vary from object to object - they are static for all reads from this table.
	
	Subclasses should override if they implement hasStaticConditions to return true"
	
	^SSWSQLConditionCollection new
]

{ #category : #validating }
SSWDBTable >> storeNonPersistentComponentsOf: aProxyObject [

	"Ensure that each non-persistency-valid component of the proxiedObject of aProxyObject 
	accessed by the receiver's components exists in the aProxyObject's ReStore 
	- store those that do not exist."
	
	| proxiedObject |
	
	proxiedObject := aProxyObject _proxiedObject.

	self dataFields do:
		[ :field | (field accessor valueIn: proxiedObject) _ensurePersistentIn: self reStore].
		
	self collectionSpecs do:
		[ :collectionSpec || collection |
		collection := collectionSpec accessor valueIn: aProxyObject.
		collection isNil ifTrue: [collection := collectionSpec newCollection].
		collection isDBProxy ifFalse: 
			[| proxy |
			proxy := aProxyObject _collectionProxyFor: collectionSpec.
			proxy _proxiedObject == collection ifFalse: 
				[proxy _setProxiedObject: collection; _referenced]]]
]

{ #category : #evaluating }
SSWDBTable >> symbolicNameFor: aSymbol [

	"Return the correct symbolic name to use for the inst var named aSymbol.
	This is usually aSymbol itself, unless an abbreviation is specified"

	^self abbreviations at: aSymbol ifAbsent: [aSymbol]
]

{ #category : #'db maintenance' }
SSWDBTable >> synchronizeDefinition [

	"Update the receiver's definition in the database accessed by its reStore"
	
	| creationTable |

	creationTable := self forCreation.
	creationTable isNil ifTrue: [^self].

	(self reStore dbIncludesTableNamed: creationTable name)
	ifTrue: 
		[creationTable 
			synchronizeFields;
			removeRedundantContainedTables]
	ifFalse: 
		[creationTable createDefinition].

	creationTable containedTables do: [ :containedTable | containedTable synchronizeDefinition].

	self reStore connection columnDescriptions removeKey: self ifAbsent: []
]

{ #category : #'db maintenance' }
SSWDBTable >> synchronizeFields [

	"Update the definition of the receiver's fields in the database accessed by reStore.
	ASSERT: the receiver exists as a table in the database"
	
	| allFields allColumns addedFields droppedColumns |

	allFields := self allFields.
	allColumns := self reStore columnsInTable: self.
	addedFields := allFields reject: [ :field | allColumns anySatisfy: [ :column | column name = field name]].
	droppedColumns := allColumns reject: [ :column | allFields anySatisfy: [ :field | field name = column name]].

	addedFields isEmpty ifFalse: [self reStore sqlDialect addFields: addedFields to: self in: self reStore].

	"Not all DBs can directly DROP COLUMN. Use the dialect's maintenance action for this"
	droppedColumns do: 
		[ :column | 
		self reStore sqlDialect 
			dropColumnNamed: column name 
			fromTable: self
			in: self reStore]
]

{ #category : #evaluating }
SSWDBTable >> withAllFields [

	"Return a table equivalent to the receiver but containing all possible fields.	
	For non-inherited tables, this is just the receiver"
	
	^self
]

{ #category : #evaluating }
SSWDBTable >> withControlFields [

	"Return a table equivalent to the receiver but containing only control fields"
	
	| withControlFields |

	withControlFields := SSWDBTable new.

	^withControlFields
		reStore: self reStore;
		name: self name;
		fullName: self fullName;
		idField: (self idField copy table: withControlFields; yourself);
		controlFields: (self controlFields collect: [ :each | each copy table: withControlFields; yourself]);
		yourself
]

{ #category : #output }
SSWDBTable >> writeSQLDefinitionOn: aStream [
	
	self isDefined ifFalse: [self error: 'Cannot create a table with no fields'].
	
	aStream
		nextPutAll: 'CREATE TABLE ';
		nextPutIdentifier: self name;
		nextPutAll: ' ('.
	
	self idField writeSQLDefinitionOn: aStream.
	aStream nextPutAll: ' PRIMARY KEY'.
		
	self dataAndControlFields do:
		[ :field |
		aStream nextPutAll: ', '.
		field writeSQLDefinitionOn: aStream].
		
	aStream nextPut: $)
]
