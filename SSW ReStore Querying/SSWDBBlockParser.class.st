"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBBlockParser,
	#superclass : #Object,
	#instVars : [
		'reStore',
		'argumentClass',
		'argumentTable',
		'referencedTables',
		'qualifyingConditions',
		'qualifyingTables',
		'orderingSpecs',
		'groupByFields',
		'activeReceiver',
		'isCollectingAssociations',
		'fieldEncounters'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #'instance creation' }
SSWDBBlockParser class >> new [

	^super new
		qualifyingConditions: SSWSQLConditionCollection forAND;
		qualifyingTables: SSWSQLLeftJoinedTableCollection new;
		groupByFields: SSWSQLFieldCollection new;
		orderingSpecs: OrderedCollection new;
		yourself
]

{ #category : #'instance creation' }
SSWDBBlockParser class >> newForReStore: anSSWReStore argumentClass: aClass [

	^self platformClass new
		reStore: anSSWReStore;
		argumentClass: aClass;
		yourself
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> _parse: aOneArgBlock [

	| blockArgument |

	blockArgument := self newBlockArgument.
	self activeReceiver: blockArgument.

	^aOneArgBlock value: blockArgument
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> _parseSortBlock: aTwoArgBlock inverted: aBoolean [

	| blockArgument |

	self reset.
	blockArgument := self newBlockArgument.
	self activeReceiver: blockArgument.

	^aBoolean
		ifTrue: [aTwoArgBlock value: SSWDBDumbArgument current value: blockArgument]
		ifFalse: [aTwoArgBlock value: blockArgument value: SSWDBDumbArgument current]
]

{ #category : #accessing }
SSWDBBlockParser >> activeReceiver [
	^activeReceiver
]

{ #category : #accessing }
SSWDBBlockParser >> activeReceiver: anObject [
	activeReceiver := anObject
]

{ #category : #accessing }
SSWDBBlockParser >> allFields [

	^SSWSQLTableAllFields forTable: self argumentTable
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> applyFunction: aString to: aField withArguments: aCollection [

	"Private - Apply the given SQL function String to the given db field.
	Return the new function field"

	^self applyFunction: aString toResultOf: [aField] withArguments: aCollection
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> applyFunction: aSQLFunction toResultOf: aBlock withArguments: aCollection [

	"Private - Apply the given SQL function to the result of aBlock (likely to be a db field).
	Ordering of extracting the receiver and arguments is important, hence deferred evaluating using aBlock.
	Return the new function field"

	| arguments |

	arguments := OrderedCollection new: aCollection size.
	aCollection reverseDo: 
		[ :arg |
		(arg isKindOf: SSWDBBlockEvaluator)
			ifTrue: [arguments addFirst: arg finalField]
			ifFalse: [arguments addFirst: arg]].
	
	^arguments size = aCollection size
		ifTrue: [aBlock value withFunction: aSQLFunction arguments: arguments asArray]
		ifFalse: [self parseError: 'No Final Field found']
]

{ #category : #accessing }
SSWDBBlockParser >> argumentClass [

	"argumentClass stores the class of object that is intended to be the single argument
	of a block being parsed by the receiver"
	
	^argumentClass
]

{ #category : #accessing }
SSWDBBlockParser >> argumentClass: aClass [

	"argumentClass stores the class of object that is intended to be the single argument
	of a block being parsed by the receiver"
	
	argumentClass := aClass
]

{ #category : #accessing }
SSWDBBlockParser >> argumentTable [

	"argumentTable stores the SSWDBTable associated with the receiver's argumentClass.
	Normally this is deduced from the reStore but can be set explicitly if different"

	^argumentTable ifNil: [self reStore tableForClass: self argumentClass]
]

{ #category : #accessing }
SSWDBBlockParser >> argumentTable: anSSWDBTable [

	"argumentTable stores the SSWDBTable associated with the receiver's argumentClass.
	Normally this is deduced from the reStore but can be set explicitly if different"

	argumentTable := anSSWDBTable
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> beUnsorted [

	self orderingSpecs: OrderedCollection new
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> collectQueryFrom: aOneArgBlock [

	"Patched for issue 120-014
	
	aOneArgBlock should be of the form [ :cd | cd releaseDate] or [ :cd | cd label name], 
	i.e. reference a Date/String/Number etc. field"

	| targetFields |

	"We need to deduce the targetFields first since this affects the behavior of newSelectQuery"
	targetFields := self targetFieldsFrom: aOneArgBlock.

	^self newSelectQuery
		fields: targetFields;
		tables: self includedTables;
		conditions: self qualifyingConditions;
		yourself
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> deleteQueryFrom: aOneArgBlock [

	| conditions |
	
	self reset.
	
	conditions := self parse: aOneArgBlock.
	(conditions isKindOf: SSWDBBlockEvaluator) ifTrue: [conditions := SSWSQLConditionCollection forAND].

	^SSWSQLDeleteQuery new
		tables: self includedTables;
		conditions: (conditions sqlAnd: self qualifyingConditions);
		yourself
]

{ #category : #accessing }
SSWDBBlockParser >> fieldEncounters [

	"fieldEncounters stores an OrderedCollection of Associations of fields -> resulting block receiver (or nil if none) encountered during a parse, in the order they were encountered"

	^fieldEncounters
]

{ #category : #accessing }
SSWDBBlockParser >> fieldEncounters: anOrderedCollection [

	"fieldEncounters stores an OrderedCollection of fields -> resulting block receiver (or nil if none) encountered during a parse, in the order they were encountered"

	fieldEncounters := anOrderedCollection
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> fieldEncountersWith: aField [

	^(self fieldEncounters select: [ :each | each key = aField]) size
]

{ #category : #accessing }
SSWDBBlockParser >> groupByFields [
	^groupByFields
]

{ #category : #accessing }
SSWDBBlockParser >> groupByFields: anObject [
	groupByFields := anObject
]

{ #category : #testing }
SSWDBBlockParser >> hasGrouping [

	^self groupByFields isEmpty not
]

{ #category : #testing }
SSWDBBlockParser >> hasOrdering [

	^self orderingSpecs isEmpty not
]

{ #category : #evaluating }
SSWDBBlockParser >> includedTables [

	"Return those tables included in the query generated by the receiver.
	This is the referencedTables, without duplicated entries"
	
	^self referencedTables withoutDuplicates
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> invertOrdering [

	self orderingSpecs: (self orderingSpecs collect: [ :each | each inverted])
]

{ #category : #accessing }
SSWDBBlockParser >> isCollectingAssociations [

	^isCollectingAssociations ifNil: [false]
]

{ #category : #accessing }
SSWDBBlockParser >> isCollectingAssociations: anObject [
	isCollectingAssociations := anObject
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> lastFieldEncounterFor: aBlockEvaluator [

	self fieldEncounters reverseDo: [ :each | each value == aBlockEvaluator ifTrue: [^each key]].

	self error: 'field encounter not found'
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> modifyQueryFrom: aOneArgBlock [

	"Patched for issue 120-009"
	
	| updates |
	
	self reset.
	
	updates := (self parseForModify: aOneArgBlock) asFieldAssignment.
	updates field table == self argumentTable ifFalse: [self error: 'Only single-table updates supported'].
	
	^SSWSQLUpdateQuery new
		tables: (SSWSQLTableCollection with: self argumentTable);
		fieldUpdates: updates;
		conditions: self qualifyingConditions;
		yourself
]

{ #category : #evaluating }
SSWDBBlockParser >> newBlockArgument [

	"Create and return a new SSWDBBlockArgument to parse a block with"
	
	^SSWDBBlockArgument new 
		parser: self; 
		currentClass: self argumentClass;
		yourself
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> newCondition [

	^SSWDBQueryCondition new
		parser: self;
		yourself
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> newConditionCollection [

	^SSWDBQueryConditionCollection new
		parser: self;
		yourself
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> newReceiverFor: aField from: aBlockEvaluator [

	"Private - Create and return a new SSWDBBlockReceiver to receive (and parse) messages for the class of object which is referenced by aField"

	| table occurrences |

	table := self reStore tableForClass: aField targetClass.

	"Check for duplicate appearances (via different links) of the same table. Alias accordingly"
	(self referencedTables tableJoinedWithField: aField)
	ifNil:
		[occurrences := self referencedTables occurrencesOf: table.
		occurrences > 0 ifTrue: [table := SSWDBQueryTable forRepetition: occurrences of: table].
		self referencedTables add: table joinedWithField: aField]
	ifNotNil: 
		[ :joinedTable | table := joinedTable].

	self activeReceiver: 
		(SSWDBBlockReceiver new
			parser: self;
			currentClass: aField targetClass;
			currentTable: table;
			path: (aBlockEvaluator path, (Array with: aField accessor));
			yourself).

	self fieldEncounters addLast: (Association key: aField value: self activeReceiver).

	^self activeReceiver
]

{ #category : #evaluating }
SSWDBBlockParser >> newSelectQuery [

	"Return a new, initialized SelectQuery of the approriate class"

	^self hasGrouping 
	ifTrue:
		[SSWSQLAggregatedOrderedSelectQuery new
			groupByFields: self groupByFields;
			orderingSpecs: self orderingSpecs;
			yourself]
	ifFalse:
		[self hasOrdering
		ifTrue: 
			[SSWSQLOrderedSelectQuery new
				orderingSpecs: self orderingSpecs;
				yourself]
		ifFalse: 
			[SSWSQLSelectQuery new]]
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> orWith: aBlockParser [

	"'OR' the receiver with the qualifying conditions of aBlockParser"

	self qualifyingConditions: (self qualifyingConditions sqlOr: aBlockParser qualifyingConditions)

]

{ #category : #accessing }
SSWDBBlockParser >> orderingSpecs [

	"orderingSpecs stores an OrderedCollection of SSWDBOrderingSpecs
	which are applied to all SelectQueries generated by the receiver.

	If empty, the query remains unordered"

	^orderingSpecs
]

{ #category : #accessing }
SSWDBBlockParser >> orderingSpecs: anOrderedCollection [

	"orderingSpecs stores an OrderedCollection of SSWDBOrderingSpecs
	which are applied to all SelectQueries generated by the receiver.

	If empty, the query remains unordered"

	orderingSpecs := anOrderedCollection
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> parse: aOneArgBlock [

	"Parse aOneArgBlock, returning the resulting SSWSQLConditionCollection"

	^(self _parse: aOneArgBlock) asSQLConditions
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> parseError: aString [

	"Raise a suitable error"
	
	^self parseError: aString with: nil
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> parseError: aString with: anObject [

	"Private - Raise a suitable error"
	
	^SSWDBParseError signal: ('Cannot parse block - ', aString) with: anObject
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> parseForModify: aOneArgBlock [

	"Private - Created for issue 120-009
	
	Parse aOneArgBlock, returning the resulting SSWSQLConditionCollection.
	Indicate to the parsing components that this is for a modify instruction"

	^aOneArgBlock value: (self newBlockArgument isForModify: true; yourself)
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> parseSortBlock: aTwoArgBlock [

	"Parse aTwoArgBlock, which should be a 'simple' sort block (see SSWDBInstancesCollection>>sortBlock)
	returning the resulting SSWSQLConditionCollection"

	| isInverted parseResult|

	isInverted := false.
	parseResult := self _parseSortBlock: aTwoArgBlock inverted: isInverted.
	parseResult == SSWDBDumbArgument current ifTrue: 
		["Consider inverse sort block, e.g. [ :a :b | b name > a name] (NB does not work in all cases)"
		isInverted := true.
		parseResult := self _parseSortBlock: aTwoArgBlock inverted: isInverted].

	isInverted ifTrue: [parseResult flattened do: [ :each | each operator invert]].

	self qualifyingTables: (self qualifyingTables merge: self referencedTables withoutDuplicates).

	^parseResult
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> popAccumulatedConditions [

	| popped |

	self accumulatedConditionsStack isEmpty ifTrue: [^self resetConditions].

	popped := self accumulatedConditionsStack removeLast.
	self 
		accumulatedConditions: popped key;
		currentConditions: popped value
]

{ #category : #copying }
SSWDBBlockParser >> postCopy [

	self
		qualifyingConditions: self qualifyingConditions copy;
		qualifyingTables: self qualifyingTables copy;
		orderingSpecs: self orderingSpecs copy;
		groupByFields: self groupByFields copy
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> projectQueryFrom: aOneArgBlock [

	"Enrich the collect query generated from aOneArgBlock to group non-aggregated fields"

	| targetFields |

	"We need to deduce the targetFields first since this affects the behavior of newSelectQuery"
	targetFields := self targetFieldsFrom: aOneArgBlock.
	targetFields isAllInTable 
		ifTrue: [targetFields table = self argumentTable ifFalse: [self groupByFields: (SSWSQLFieldCollection with: targetFields table idField)]]
		ifFalse: [self groupByFields: (targetFields reject: [ :each | each hasAggregateFunction])].

	^self newSelectQuery
		fields: targetFields;
		tables: self includedTables;
		conditions: self qualifyingConditions;
		yourself
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> pushAccumulatedConditions [

	self accumulatedConditionsStack addLast: (self accumulatedConditions -> self currentConditions).
	self resetConditions
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> qualifyWith: aOneArgBlock [

	"Set the receiver's qualifyingCondition based on aOneArgBlock"

	| parsed |

	self reset.
	
	parsed := self parse: aOneArgBlock.
	(parsed isKindOf: SSWDBBlockEvaluator) ifTrue: [parsed := parsed implicitEqualsTrue].

	self 
		qualifyingConditions: (self qualifyingConditions sqlAnd: parsed);
		qualifyingTables: (self qualifyingTables merge: self referencedTables withoutDuplicates)
]

{ #category : #accessing }
SSWDBBlockParser >> qualifyingConditions [

	"qualifyingConditions stores a static condition collection which is ANDed with 
	the conditions of any query generated by the receiver (empty by default).
	
	This enables the receiver to be used for queries focusing on a subset of a table, 
	e.g. if the receiver's qualifyingConditions were (equivalent to) [ :cd | cd label name = '4AD'],
	then the receiver could be used to focus only on CDs issued by 4AD"
	
	^qualifyingConditions
]

{ #category : #accessing }
SSWDBBlockParser >> qualifyingConditions: anSSWSQLConditionCollection [

	"qualifyingConditions stores a static condition collection which is ANDed with 
	the conditions of any query generated by the receiver (empty by default).
	
	This enables the receiver to be used for queries focusing on a subset of a table, 
	e.g. if the receiver's qualifyingConditions were (equivalent to) [ :cd | cd label name = '4AD'],
	then the receiver could be used to focus only on CDs issued by 4AD"
	
	qualifyingConditions := anSSWSQLConditionCollection
]

{ #category : #accessing }
SSWDBBlockParser >> qualifyingTables [

	"qualifyingTables stores the tables encountered when creating qualifyingConditions"
	
	^qualifyingTables
]

{ #category : #accessing }
SSWDBBlockParser >> qualifyingTables: anSSWSQLJoinedTableCollection [

	"qualifyingTables stores the tables encountered when creating qualifyingConditions"
	
	qualifyingTables := anSSWSQLJoinedTableCollection
]

{ #category : #accessing }
SSWDBBlockParser >> reStore [

	"reStore stores the SSWReStore for which the receiver parses blocks"
	
	^reStore
]

{ #category : #accessing }
SSWDBBlockParser >> reStore: anSSWReStore [

	"reStore stores the SSWReStore for which the receiver parses blocks"
	
	reStore := anSSWReStore
]

{ #category : #accessing }
SSWDBBlockParser >> referencedTables [

	"referencedTables stores the SSWDBTables that are referenced when parsing a block,
	in the order in which they were referenced, together with the joining fields 
	(SSWJoinedTableCollection hold both together"
	
	^referencedTables
]

{ #category : #accessing }
SSWDBBlockParser >> referencedTables: anSSWJoinedTableCollection [

	"referencedTables stores the SSWDBTables that are referenced when parsing a block,
	in the order in which they were referenced, together with the joining fields 
	(SSWJoinedTableCollection hold both together"
	
	referencedTables := anSSWJoinedTableCollection
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> rejectQueryFrom: aOneArgBlock [

	| conditions |
	
	self reset.
	"Invert (not) the parse: result to turn select into reject"
	conditions := (self parse: aOneArgBlock) not.

	^self newSelectQuery
		fields: self allFields;
		tables: self includedTables;
		conditions: (conditions sqlAnd: self qualifyingConditions);
		yourself
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> removeFieldEncountersWith: aField [

	self fieldEncounters: (self fieldEncounters reject: [ :each | each key == aField])
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> reset [

	"Reset the receiver for a new parsing session"

	self referencedTables: (SSWSQLLeftJoinedTableCollection with: self argumentTable).
	
	self qualifyingTables isNil ifFalse: [self referencedTables merge: self qualifyingTables].

	self
		groupByFields: SSWSQLFieldCollection new;
		fieldEncounters: (self referencedTables joinFields collect: [ :each | each -> nil])
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> resetConditions [

	self
		currentConditions: self newConditionCollection;
		accumulatedConditions: self currentConditions;
		isAccumulatingConditions: false
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> selectQueryFrom: aOneArgBlock [

	| conditions |
	
	self reset.

	conditions := self parse: aOneArgBlock.

	^self newSelectQuery
		fields: self allFields;
		tables: self includedTables;
		conditions: (conditions sqlAnd: self qualifyingConditions);
		yourself
]

{ #category : #'parsing - api' }
SSWDBBlockParser >> sortBlock: aTwoArgBlock [

	| sortConditions |

	sortConditions := 
		[self parseSortBlock: aTwoArgBlock] on: SSWDBParseError do:
			[ :error | 
			error isFinalFieldError
				ifTrue: [error resume: nil]
				ifFalse: [error pass]].

	"For SQL ordering we require a flat collection. Also equality conditions are ignored.
	Thus (e.g.) 
		(p1 surname < p2 surname) | ((p1 surname = p2 surname) & (p1 firstName < p2 firstName))
	becomes:
		order by SURNAME asc, FIRST_NAME asc"
	sortConditions := sortConditions flattened reject: [ :each | each operator messageSelector = #=].

	self orderingSpecs: (sortConditions collect: [ :each | each asOrderingSpec])
]

{ #category : #evaluating }
SSWDBBlockParser >> tableForClass: aClass [

	^aClass == self argumentClass 
		ifTrue: [self argumentTable]
		ifFalse: [self reStore tableForClass: aClass]
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> targetFieldsFrom: aOneArgBlock [
	
	| targetFields nonAggregateFields |

	self reset.
	targetFields := (self _parse: aOneArgBlock) asSQLFields.

	"Parse result can be a single field or multiple depending on the block, e.g. [ :each | each name] or [ :each | each name || each age]"
	targetFields isFieldCollection ifFalse: [targetFields := SSWSQLFieldCollection with: targetFields].

	"If we have accumulated aggregated functions, ensure groupByFields are updated accordingly"
	nonAggregateFields := targetFields reject: [ :each | each hasAggregateFunction].
	nonAggregateFields size < targetFields size ifTrue: [self groupByFields: nonAggregateFields].

	^targetFields
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> unprocessedConditionsCombinedForConcatenation: aBlockEvaluatorOrCondition [

	^aBlockEvaluatorOrCondition forConcatenation
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> unprocessedConditionsCombinedWithArgument: aCondition [

	^aCondition
]

{ #category : #'parsing - internal' }
SSWDBBlockParser >> unprocessedConditionsCombinedWithReceiver: aCondition [

	^aCondition
]
