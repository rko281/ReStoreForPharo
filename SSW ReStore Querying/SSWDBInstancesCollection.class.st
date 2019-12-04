"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBInstancesCollection,
	#superclass : #Object,
	#instVars : [
		'reStore',
		'instancesClass',
		'parser',
		'sortBlock',
		'preFetchComponents',
		'preReadActions',
		'postReadActions'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #'instance creation' }
SSWDBInstancesCollection class >> forClass: aClass in: anSSWReStore [

	^self new
		instancesClass: aClass;
		reStore: anSSWReStore;
		createParser;
		yourself
]

{ #category : #'instance creation' }
SSWDBInstancesCollection class >> new [

	^super new
		preReadActions: OrderedCollection new;
		postReadActions: OrderedCollection new;
		yourself
]

{ #category : #actions }
SSWDBInstancesCollection >> addAll: anSSWDBInstancesCollection [

	"'Add' the given instances collection to the receiver so that its elements
	are added to the receiver's following a query"

	"Can only add same/inherited classes"
	(self instancesClass = anSSWDBInstancesCollection instancesClass or:
		[self instancesClass = 
			(self reStore tableForClass: anSSWDBInstancesCollection instancesClass) rootClass])
				ifFalse: [self error: 'Cannot add unrelated instances collections'].

	self parser orWith: anSSWDBInstancesCollection parser.

	"Behave like a collection and return the added object"
	^anSSWDBInstancesCollection
]

{ #category : #enumerating }
SSWDBInstancesCollection >> allSatisfy: aBlock [

	"Uses two queries"
	
	^self size = (self satisfying: aBlock) size
]

{ #category : #enumerating }
SSWDBInstancesCollection >> anySatisfy: aBlock [
	
	"Uses one query"

	^(self satisfying: aBlock) isEmpty not
]

{ #category : #converting }
SSWDBInstancesCollection >> asOrderedCollection [

	^self collectInto: (OrderedCollection new: 16)
]

{ #category : #converting }
SSWDBInstancesCollection >> asSet [

	^self collectInto: (Set new: 16)
]

{ #category : #converting }
SSWDBInstancesCollection >> asSortedCollection [

	"If a sort is already defined, use that, else use the standard sort block"

	^self isSorted
		ifTrue: [self collectInto: (SortedCollection sortBlock: self sortBlock)]
		ifFalse: [self asSortedCollection: SortedCollection defaultSortBlock]
]

{ #category : #converting }
SSWDBInstancesCollection >> asSortedCollection: aTwoArgBlock [

	^self copy
		sortBlock: aTwoArgBlock;
		asSortedCollection
]

{ #category : #enumerating }
SSWDBInstancesCollection >> collect: collectBlock [
	
	^self collect: collectBlock into: (OrderedCollection new: 16)
]

{ #category : #helpers }
SSWDBInstancesCollection >> collect: collectBlock into: aCollection [

	"Private - Add the objects resulting from collectBlock to aCollection.
	Return aCollection"
	
	^self query: (self parser collectQueryFrom: collectBlock) into: aCollection
]

{ #category : #helpers }
SSWDBInstancesCollection >> collectInto: aCollection [

	"Private - Add the objects resulting from the receiver to aCollection.
	Return aCollection"
	
	^self collect: [ :object | object] into: aCollection
]

{ #category : #copying }
SSWDBInstancesCollection >> copy [

	^self shallowCopy
		parser: self parser copy;
		yourself
		
]

{ #category : #initializing }
SSWDBInstancesCollection >> createParser [

	self parser: (SSWDBBlockParser newForReStore: self reStore argumentClass: self instancesClass)

]

{ #category : #enumerating }
SSWDBInstancesCollection >> detect: detectBlock [

	^self detect: detectBlock ifNone: [self errorNotFound: detectBlock]
]

{ #category : #enumerating }
SSWDBInstancesCollection >> detect: detectBlock ifNone: noneBlock [

	| query |
	
	query := self parser selectQueryFrom: detectBlock.

	^self reStore fetchObjectOfClass: self instancesClass withQuery: query ifNone: noneBlock
]

{ #category : #enumerating }
SSWDBInstancesCollection >> do: aBlock [

	"Use the streamed #do: to avoid creating a (potentially large) temporary collection"
	
	| stream |

	stream := self readStream.

	[stream do: aBlock] ensure: [stream close]
]

{ #category : #helpers }
SSWDBInstancesCollection >> fetchObjectsWithQuery: aQuery into: aCollection [

	self preReadActions do: [ :each | each value].

	self reStore fetchObjectsOfClass: self instancesClass withQuery: aQuery into: aCollection.
	
	self postReadActions do: [ :each | each value: aCollection].

	^aCollection
]

{ #category : #evaluating }
SSWDBInstancesCollection >> first [

	^self detect: [ :each | true] ifNone: [#() errorSubscriptBounds: 1]
]

{ #category : #evaluating }
SSWDBInstancesCollection >> first: anInteger [

	| stream collection |

	stream := self readStream.
	collection := OrderedCollection new: anInteger.

	anInteger timesRepeat: [collection add: stream next].

	^collection
]

{ #category : #testing }
SSWDBInstancesCollection >> includes: anObject [

	| id |

	id := (anObject _dbProxyIfNone: [^false]) _id.

	^(self detect: [ :each | each _id = id] ifNone: [nil]) == anObject
]

{ #category : #accessing }
SSWDBInstancesCollection >> instancesClass [

	"instancesClass stores the Class of persistent object which form the receiver's 'elements'	"
	
	^instancesClass
]

{ #category : #accessing }
SSWDBInstancesCollection >> instancesClass: aClass [

	"instancesClass stores the Class of persistent object which form the receiver's 'elements'	"
	
	instancesClass := aClass
]

{ #category : #testing }
SSWDBInstancesCollection >> isEmpty [

	^self size = 0
]

{ #category : #testing }
SSWDBInstancesCollection >> isSorted [

	^self sortBlock notNil
]

{ #category : #evaluating }
SSWDBInstancesCollection >> last [

	^self readStream last
]

{ #category : #enumerating }
SSWDBInstancesCollection >> lookup: aBlock [

	^self detect: aBlock ifNone: [nil]
]

{ #category : #enumerating }
SSWDBInstancesCollection >> modify: aBlock [

	"Iterate over the elements in the database, modifying each according to aBlock.
	e.g. say the receiver represents all CDs with no artist assigned, then:

		self modify: [ :cd | cd artist: 'Unknown']
		
	...would update all instances in the database.	This can be compared to do:, except that:	
	 - modify: does not bring all instances into memory (uses a single query)
	 - aBlock must be a reasonably simple inst var update
	 - the number of modified rows is returned as the result"
	
	| query rows |
	
	query := self parser modifyQueryFrom: aBlock.

	((self reStore objectProxyClassFor: self instancesClass) modifyUpdatesFor: self table) do: 
		[ :each || subQuery |
		self parser reset.
		subQuery := self parser modifyQueryFrom: each.
		query fieldUpdates: (query fieldUpdates, subQuery fieldUpdates)].

	self reStore evaluateInTxn: [rows := self reStore executeQuery: query. true].
	
	^rows
]

{ #category : #accessing }
SSWDBInstancesCollection >> parser [

	"parser stores an SSWDBBlockParser which parses enumerating blocks
	to generate corresponding SSWSQLQueries"
	
	^parser
]

{ #category : #accessing }
SSWDBInstancesCollection >> parser: anSSWDBBlockParser [

	"parser stores an SSWDBBlockParser which parses enumerating blocks
	to generate corresponding SSWSQLQueries"
	
	parser := anSSWDBBlockParser
]

{ #category : #accessing }
SSWDBInstancesCollection >> postReadActions [

	"postReadActions stores an OrderedCollection of actions (1-arg Blocks or MessageSends) which are evaluated with a collection of the receiver's elements after they are read from the database"

	^postReadActions
]

{ #category : #accessing }
SSWDBInstancesCollection >> postReadActions: anOrderedCollection [

	"postReadActions stores an OrderedCollection of actions (1-arg Blocks or MessageSends) which are evaluated with a collection of the receiver's elements after they are read from the database"

	postReadActions := anOrderedCollection
]

{ #category : #accessing }
SSWDBInstancesCollection >> preReadActions [

	"preReadActions stores an OrderedCollection of actions (zero-arg Blocks or MessageSends) which are evaluated before the receiver's elements are read from the database"

	^preReadActions
]

{ #category : #accessing }
SSWDBInstancesCollection >> preReadActions: anOrderedCollection [

	"preReadActions stores an OrderedCollection of actions (zero-arg Blocks or MessageSends) which are evaluated before the receiver's elements are read from the database"

	preReadActions := anOrderedCollection
]

{ #category : #enumerating }
SSWDBInstancesCollection >> project: projectBlock [
	
	^self project: projectBlock into: (OrderedCollection new: 16)
]

{ #category : #helpers }
SSWDBInstancesCollection >> project: projectBlock into: aCollection [

	"Private - Add the objects resulting from projectBlock to aCollection.
	Return aCollection"

	^self query: (self parser projectQueryFrom: projectBlock) into: aCollection
]

{ #category : #initializing }
SSWDBInstancesCollection >> qualifyWith: aBlock [

	"Modify the receiver's parser so that it always qualifies any query it creates
	with the conditions extracted from aBlock"
	
	self parser qualifyWith: aBlock

]

{ #category : #helpers }
SSWDBInstancesCollection >> query: query into: aCollection [

	"Private - Add the objects resulting from query to aCollection.
	Return aCollection"

	"If a field-based collect block e.g. [ :cd | cd title] then there will be only one query field.
	If a 'target object' collect block e.g. [ :cd | cd] then the query field will be 'all fields in table'		"
	query fields isAllInTable
	ifTrue:
		[self fetchObjectsWithQuery: query into: aCollection]
	ifFalse:
		[self reStore rowsFromQuery: query do: 
			[ :row |
			query fields size = 1
			ifTrue:
				[aCollection add: (query fields first convertValue: (row atIndex: 1))]
			ifFalse:
				[| values |
				values := aCollection add: (Array new: query fields size).
				query fields keysAndValuesDo:
					[ :index :field || dbValue |
					dbValue := row atIndex: index.
					values at: index put: (field convertValue: dbValue)]]]].
		
	^self parser isCollectingAssociations
		ifTrue: [aCollection collect: [ :pair | pair first -> pair last]]
		ifFalse: [aCollection]
]

{ #category : #accessing }
SSWDBInstancesCollection >> reStore [

	"reStore stores the SSWReStore in which the receiver's 'elements' reside"
	
	^reStore
]

{ #category : #accessing }
SSWDBInstancesCollection >> reStore: anSSWReStore [

	"reStore stores the SSWReStore in which the receiver's 'elements' reside"
	
	reStore := anSSWReStore
]

{ #category : #evaluating }
SSWDBInstancesCollection >> readStream [

	"Create and return an appropraite ReadStream-like object on the receiver"
	
	^SSWDBReadStream on: self
]

{ #category : #initializing }
SSWDBInstancesCollection >> refreshed [

	"Arrange for a softRollback to take place immediately before reading the receiver's elements from the database.
	This will ensure any objects already in the image are refreshed with the newly-fetched rows"

	self preReadActions add: [self reStore softRollback]
]

{ #category : #enumerating }
SSWDBInstancesCollection >> reject: rejectBlock [
	
	| query results |
	
	query := self parser rejectQueryFrom: rejectBlock.
	
	results := OrderedCollection new.
		
	self fetchObjectsWithQuery: query into: results.
	
	^results
]

{ #category : #evaluating }
SSWDBInstancesCollection >> resultSet [

	"Return a DBResultSet (open query results) onto the collection of rows
	represented by the receiver"
	
	| query |
	
	query := self parser collectQueryFrom: [ :elem | elem].
	
	"Always use #keysetDriven to give a flexible, efficient result set"
	^self reStore executeQuery: query cursorType: #keysetDriven
]

{ #category : #enumerating }
SSWDBInstancesCollection >> satisfying: aOneArgBlock [

	"Return a copy of the receiver, but with its members qualified by aOneArgBlock,
	in addition to the receiver's existing qualifiers (if any).
	
	This is similar to a select:, but returns another SSWDBInstancesCollection,
	rather than a real collection of real instances.	Useful as an enumerating 'step' e.g.
		(anInstancesCollection select: [ :cd | cd label name = '4AD']) collect: [ :cd | cd title]
		(anInstancesCollection satisfying: [ :cd | cd label name = '4AD']) collect: [ :cd | cd title]
	Both would get the title of all CDs released by 4AD, but the second would do this
	without having to fault in all CD instances from the database"
	
	^self copy
		qualifyWith: aOneArgBlock;
		yourself
]

{ #category : #enumerating }
SSWDBInstancesCollection >> select: selectBlock [
	
	| query results |
	
	query := self parser selectQueryFrom: selectBlock.
	
	results := OrderedCollection new.
			
	self fetchObjectsWithQuery: query into: results.
	
	^results
]

{ #category : #enumerating }
SSWDBInstancesCollection >> select: selectBlock thenCollect: collectBlock [

	"This method is compatible with Collection>>select:thenCollect: but uses satisfying: to avoid faulting in all instances of the receiver's instanceClass"
	
	^(self satisfying: selectBlock) collect: collectBlock
]

{ #category : #evaluating }
SSWDBInstancesCollection >> size [

	"Evaluate the 'size' (number of persistent instances) of the receiver via a COUNT query"
	
	| query size |

	query := self parser projectQueryFrom: [ :object | object count].

	"Ordering unnecessary for simple count query"
	query hasOrdering ifTrue: [query forgetOrdering].
			
	self reStore rowsFromQuery: query do: [ :row | size := row atIndex: 1].
	
	^size
]

{ #category : #accessing }
SSWDBInstancesCollection >> sortBlock [

	"Order the receiver's elements by aTwoArgBlock - a 'simple' sort block:
	 - only >, >=, <, <= comparisons (= is redundant and ignored for SQL translation)
	 - only & and | conjunctions
	 - comparisons on same field only

	e.g. 	[ :p1 :p2 | 
		(p1 surname < p2 surname) |  ((p1 surname = p2 surname) & (p1 forename < p2 forename))]"

	^sortBlock
]

{ #category : #accessing }
SSWDBInstancesCollection >> sortBlock: aTwoArgBlock [

	"Order the receiver's elements by aTwoArgBlock - a 'simple' sort block:
	 - only >, >=, <, <= comparisons (= is redundant and ignored for SQL translation)
	 - only & and | conjunctions
	 - comparisons on same field only

	e.g. 	[ :p1 :p2 | 
		(p1 surname < p2 surname) |  ((p1 surname = p2 surname) & (p1 forename < p2 forename))]"

	sortBlock := aTwoArgBlock.

	aTwoArgBlock isNil
		ifTrue: [self parser beUnsorted]
		ifFalse: [self parser sortBlock: aTwoArgBlock]
]

{ #category : #evaluating }
SSWDBInstancesCollection >> table [

	"Return the table associated with the receiver's instancesClass"
	
	"The Parser knows this"
	^self parser argumentTable
]

{ #category : #actions }
SSWDBInstancesCollection >> unstore: aBlock [

	"Unstore elements of the receiver satisfying aBlock from the database
	Return the number of rows deleted"

	| rows |

	self reStore evaluateInTxn: 
		[rows := self reStore executeQuery: (self parser deleteQueryFrom: aBlock).
		true].

	^rows
]

{ #category : #actions }
SSWDBInstancesCollection >> unstoreAll [

	"Unstore all elements of the receiver from the database"

	^self unstore: [ :each | true]
]

{ #category : #initializing }
SSWDBInstancesCollection >> withComponent: aSymbol [

	"Arrange for the content of the inst var named aSymbol to be bulk fetched when elements of the receiver are read from the database"

	self withComponents: (Array with: aSymbol)
]

{ #category : #initializing }
SSWDBInstancesCollection >> withComponents: aCollectionOfInstVarNames [

	"Arrange for the contents of aCollectionOfInstVarNames (representing components of the receiver) to be bulk fetched when elements of the receiver are read from the database"

	self withTableComponents: (aCollectionOfInstVarNames collect: [ :instVarName | self table componentAccessing: instVarName])
]

{ #category : #initializing }
SSWDBInstancesCollection >> withDependentComponents [

	"Arrange for dependent contents to be bulk pre-fetched when elements of the receiver are read from the database"

	self withTableComponents: self table dependentComponents
]

{ #category : #initializing }
SSWDBInstancesCollection >> withRelatedComponents [

	"Arrange for related contents to be bulk pre-fetched when elements of the receiver are read from the database"

	self withTableComponents: self table relatedComponents
]

{ #category : #initializing }
SSWDBInstancesCollection >> withTableComponents: aCollectionOfTableComponents [

	"Private - Arrange for the contents of aCollectionOfTableComponents to be bulk fetched when elements of the receiver are read from the database"

	aCollectionOfTableComponents do: 
		[ :component | 
		self postReadActions add: [ :elements | component readAllFor: elements]]
]

{ #category : #evaluating }
SSWDBInstancesCollection >> withoutInheritance [

	"If the receiver's instancesClass has persistent subclasses, then by default
	instances of those subclasses are included in the receiver 'collection'.
	
	Prevent this behaviour by restricting to only elements of the instancesClass"
	
	^self satisfying: [ :each | each class = self instancesClass]
]
