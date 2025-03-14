"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBBlockArgument',
	#superclass : 'SSWDBBlockEvaluator',
	#instVars : [
		'currentClass',
		'isForModify',
		'finalFields'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'instance creation' }
SSWDBBlockArgument class >> new [

	^super new
		finalFields: (OrderedCollection new: 2);
		yourself
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> & aValue [

	"Sent in case of an implicit '= true' expression, or possibly Integer bit manipulation"

	^self implicitEqualsTrue 
		ifNil: [self doesNotUnderstand: (MessageSend receiver: self selector: #& argument: aValue)]
		ifNotNil: [ :result | result & aValue]
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> -> aBlockEvaluator [

	"Convenience method for collect: and project: query blocks returning two results; allow the results to be returned as an Association"

	self parser isCollectingAssociations: true.

	^self || aBlockEvaluator
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> _cacheDictionaryKey_ [

	"Special selector to locate the key for general cache dictionaries.
	This needs to locate the current collection spec and evaluate its keyAccessor with the target object"

	| frame |

	frame := self stackFrameDetect: [ :each | each method ifNil: [false] ifNotNil: [ :method | method selector = #localAnySatisfy:]].
	frame isNil ifTrue: [self parseError: 'could not locate dictionary spec'].

	^frame receiver collectionSpec keyAccessor value: (self doesNotUnderstand: (Message selector: #target))
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> _doesNotUnderstand: aMessage [

	| selector arguments |

	selector := aMessage selector.
	arguments := aMessage arguments.
	
	"If we have a finalField, attempt to interpret selector as a function message send"
	(self reStore sqlDialect sqlFunctionFor: selector) ifNotNil: 
		[ :function | 
		^self applyFunction: function withArguments: arguments].

	^arguments isEmpty
	ifTrue:
		[(self currentTable fieldAccessing: selector) 
		ifNil: 
			[(self currentTable collectionAccessing: selector)
				ifNil: [self simulateMessageSend: aMessage]
				ifNotNil: [ :collection | self newCollectionReceiverFor: collection]]
		ifNotNil: 
			[ :field |
			field isInlined "Need explicit check for inlined fields"
			ifTrue: 
				[self newInlinedReceiverFor: selector] 
			ifFalse: 
				[(field targetClass isPersistentIn: self reStore)
					ifTrue: [self newReceiverFor: field]
					ifFalse: [self finalField: (self queryFieldFor: field)]]]]
	ifFalse:
		["arguments size > 1 ifTrue: [self parseError: 'Cannot support more than one comparison argument']."
		(self hasFinalField not and: [self currentClass isPersistentBaseClass not and: [arguments last == SSWDBDumbArgument current]]) ifTrue: 
			["Sort block parsing"
			^self simulateMessageSend: aMessage].
		selector last = $: ifTrue: 
			["Check for 'assignment' in modify: block"
			(self currentTable fieldAccessing: selector allButLast asSymbol) isNil ifFalse: [^(self forModify perform: selector allButLast asSymbol) value: arguments first]].
		self sqlConditionFor: aMessage]
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> applyFunction: aString withArguments: aCollection [

	"Apply the given SQL function String to the finalField"

	self finalField: (self parser applyFunction: aString toResultOf: [self finalField] withArguments: aCollection)
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> asSQLConditions [

	"Polymorphic with DBQueryCondition(Collection)"

	^self hasFinalField 
		ifTrue: [self implyTrue: SSWSQLCondition new]
		ifFalse: [self error: 'cannot determine a valid condition']
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> asSQLFields [

	"Polymorphic with DBQueryCondition(Collection), DBQueryFieldCollection.
	If we don't have a final field then we're interested in the actual object so return all fields"

	^self hasFinalField 
		ifTrue: [SSWSQLFieldCollection with: self finalField]
		ifFalse: [SSWSQLTableAllFields forTable: self currentTable]
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> at: anIndex [

	"SQL does not differentiate between 1-char Strings and Characters.
	Therefore turn this into a midString:from: extraction of a single char"
	
	^self midString: 1 from: anIndex
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> class [

	"Override to handle as DNU (happens automatically but this implementation makes this explicit)
	 - enables comparions based on clasx for persistent class hierarchies.
	
	NB complicates debugging/inspection - see isKindOf:, printOn:"
	
	^self doesNotUnderstand: (Message selector: #class arguments: #())
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> copyFrom: startPos to: endPos [

	"Turn into a midString:from: (handled via DNU)"
	
	self midString: ((endPos - startPos) + 1) from: startPos
]

{ #category : 'parsing - aggregations' }
SSWDBBlockArgument >> count [

	"Turn into SQL function via DNU - typically COUNT(field)"

	"Allow counting of actual objects by counting unique ids"
	self hasFinalField ifFalse: [self _id].

	^self doesNotUnderstand: (Message selector: #count arguments: #())
]

{ #category : 'accessing' }
SSWDBBlockArgument >> currentClass [

	"currentClass stores the class of object which is the receiver of the next message in the block being parsed"
	
	^currentClass
]

{ #category : 'accessing' }
SSWDBBlockArgument >> currentClass: aClass [

	"currentClass stores the class of object which is the receiver of the next message in the block being parsed"
	
	currentClass := aClass
]

{ #category : 'accessing' }
SSWDBBlockArgument >> currentTable [

	"Return the table associated with the currentClass. By default, this is requested from the parser.
	Subclasses which have other requirements may override"

	^self parser tableForClass: self currentClass
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> doesNotUnderstand: aMessage [

	self parser activeReceiver: self.

	^self postProcessDNU: (self _doesNotUnderstand: aMessage)
]

{ #category : 'accessing' }
SSWDBBlockArgument >> finalField [

	"Return the last field in the finalFields queue; error if none.
	NB - this also REMOVES the last finalField, destructively changing the queue.
	Use peekFinalField or hasFinalField (non destructive) to test.

	The finalField is the last field that is referenced when parsing a block; usually also the subject of an operator, e.g.
	[ :cd | cd label address postcode = 'WC1 1AA'] - finalField would be POSTCODE."

	^self hasFinalField
		ifTrue: [self finalFields removeLast]
		ifFalse: [self currentTable ifNil: [self parseError: 'No finalField set' with: #finalField] ifNotNil: [ :table | table idField copy targetClass: table instanceClass; yourself]]
]

{ #category : 'accessing' }
SSWDBBlockArgument >> finalField: aField [

	"Add aField to the end of the finalFields queue.

	The finalField is the last field that is referenced when parsing a block; usually also the subject of an operator, e.g.
	[ :cd | cd label address postcode = 'WC1 1AA'] - finalField would be POSTCODE."

	self finalFields addLast: aField
]

{ #category : 'accessing' }
SSWDBBlockArgument >> finalFields [

	"finalFields stores an OrderedCollection of SSWDBQueryFields as a queue of 'final fields' encountered during parsing;
	There will be at most two final fields, e.g.
		[ :cd | cd title = 'Come on Pilgrim']		- 1 final field, TITLE
		[ :cd | cd title = cd artistName]			- 2 final fields, TITLE and ARTIST_NAME
		
	The Queue nature is caused by the order or parsing, e.g. 
	Parse: 'cd title'				#(TITLE)
	Parse: 'cd artistName'	#(TITLE ARTIST_NAME)
	When evaluating the '=' comparator, TITLE is compared (first) with ARTIST_NAME, i.e First In, First Out"
		
	^finalFields
]

{ #category : 'accessing' }
SSWDBBlockArgument >> finalFields: anOrderedCollection [

	"finalFields stores an OrderedCollection of SSWDBQueryFields as a queue of 'final fields' encountered during parsing;
	There will be at most two final fields, e.g.
		[ :cd | cd title = 'Come on Pilgrim']		- 1 final field, TITLE
		[ :cd | cd title = cd artistName]			- 2 final fields, TITLE and ARTIST_NAME
		
	The Queue nature is caused by the order or parsing, e.g. 
	Parse: 'cd title'				#(TITLE)
	Parse: 'cd artistName'	#(TITLE ARTIST_NAME)
	When evaluating the '=' comparator, TITLE is compared (first) with ARTIST_NAME, i.e First In, First Out"
		
	finalFields := anOrderedCollection
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> first [

	"Turn into at: 1"
	
	^self at: 1
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> forModify [

	^self parser newBlockArgument
]

{ #category : 'testing' }
SSWDBBlockArgument >> hasFinalField [

	^self finalFields isEmpty not
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> implicitEqualsTrue [

	"If the receiver has parsed an implicait Boolean test (e.g. [ :cd | cd isDeleted]),
	then the eventual result will be the receiver instead of an SQLCondition.
	
	Transform the receiver into the correct Condition"

	^(self hasFinalField and: [self peekFinalField targetClass == Boolean])
		ifTrue: [self implyTrue: self newCondition]
		ifFalse: [nil]
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> implyTrue: aCondition [

	"Private - Initialize aCondition to represent the implicit truth of the receiver's finalField, returning the condition"

	"Some dialects (SQL Server) require an actual equality test"
	self reStore sqlDialect supportsImplicitTrueConditions
		ifTrue: [aCondition fieldOnly: self finalField]
		ifFalse: [aCondition field: self finalField equalTo: true].

	^aCondition
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> indexOf: aCharacter [

	"SQL does not differentiate between Characters and Strings.
	Turn into indexOfSubCollection: (parsed via DNU)"
	
	^self indexOfSubCollection: (String with: aCharacter)
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> isEmpty [

	"Turn into the message sequence 'size = 0';
	or could be sent following an implicit = true"
	
	^(self hasFinalField and: [self peekFinalField targetClass == Boolean])
		ifTrue: [self = true]
		ifFalse: [self size = 0]
]

{ #category : 'accessing' }
SSWDBBlockArgument >> isForModify [

	^isForModify ifNil: [false]
]

{ #category : 'accessing' }
SSWDBBlockArgument >> isForModify: aBoolean [

	isForModify := aBoolean
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> isKindOf: aClass [ 

	"Overriden due to 'odd' behaviour of #class in the receiver"

	^(Array 
		with: SSWDBBlockEvaluator
		with: SSWDBBlockArgument
		with: SSWDBBlockReceiver) includes: aClass
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> leftString: lenInteger [

	"Dolphin #leftString:from: message - turn into a midString:from: (handled via DNU)"
	
	^self midString: lenInteger from: 1
]

{ #category : 'parsing - comparisons' }
SSWDBBlockArgument >> matches: aString [

	"Essentially the inverse of match: (ie pattern is the argument, not the receiver)	
	Equivalent to like: (which is handled via DNU) but translate Dolphin-specific wildcards"
	
	^self like: 
		(aString collect: 
			[ :char || fixedChar |
			fixedChar := char.
			char = $* ifTrue: [fixedChar := $%].
			char = $# ifTrue: [fixedChar = $_].
			fixedChar])
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> mustBeBoolean [

	"Only sent in case of an implicit '= true' expression (or an error)"

	^self implicitEqualsTrue 
]

{ #category : 'helpers' }
SSWDBBlockArgument >> newCollectionReceiverFor: aCollectionSpec [

	^aCollectionSpec dbBlockCollectionReceiver
		parser: self parser;
		yourself
]

{ #category : 'helpers' }
SSWDBBlockArgument >> newInlinedReceiverFor: aSymbol [

	^SSWDBInlinedBlockReceiver new
		parser: self parser;
		currentClass: self currentClass;
		inlinedInstVar: aSymbol;
		yourself
]

{ #category : 'helpers' }
SSWDBBlockArgument >> newReceiverFor: aField [

	"Create and return a new SSWDBBlockReceiver to receive (and parse) messages for the class of object which is referenced by aField"

	| newReceiver |

	newReceiver := self parser newReceiverFor: aField from: self.

	self isForModify ifTrue:
		[newReceiver
			finalField: (self queryFieldFor: aField);
			isForModify: true].

	^newReceiver
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> not [

	"Only sent in case of an implicit '= true' expression (or an error)"

	^self implicitEqualsTrue not
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> parseError: aString [

	^self parser parseError: aString
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> parseError: aString with: anObject [

	^self parser parseError: aString with: anObject
]

{ #category : 'evaluating' }
SSWDBBlockArgument >> peekFinalField [

	"Return the first field in the finalFields queue (if any) WITHOUT modifying the queue.
	c.f. finalField"

	^self hasFinalField
		ifTrue: [self finalFields last]
		ifFalse: [nil]
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> queryFieldFor: aField [

	^SSWDBQueryTableField forField: aField in: self currentTable path: self path
]

{ #category : 'parsing - functions' }
SSWDBBlockArgument >> replaceFrom: start to: stop with: replacementElements startingAt: startAt [

	"Turn this into replaceFrom:length:with: (handled via DNU) which is supported by some DBs"
	
	| length |
	
	length := (stop - start) + 1.
	
	^self replaceFrom: start length: length with: (replacementElements copyFrom: startAt to: ((startAt + length) - 1))
]

{ #category : 'helpers' }
SSWDBBlockArgument >> simulateMessageSend: aMessage [

	"Attempt to simulate the method named aSymbol in the current class's methodDictionary, turning it into equivalent SQL function(s).
	Limitations - the method (and any methods it invokes) must NOT directly access inst vars, other than simple getter accessor methods.
	Also any messages sent my the method must map to SQL functions in the current dialect.
	If any of these do not hold true a parseError will occur (or possibly something weirder)"

	self hasFinalField ifTrue: [(self simulateMessageSendToFinalField: aMessage) ifNotNil: [ :result | ^result]].

	^(self currentClass lookupMethod: aMessage selector)
		ifNil: [self parseError: '<1d> does not implement <2p>' << {self currentClass. aMessage selector}]
		ifNotNil: 
			[ :method | 
			method == (Object>>#=)
				ifTrue: [self sqlConditionFor: aMessage]
				ifFalse: [self simulateMethod: method withArguments: aMessage arguments]]
]

{ #category : 'helpers' }
SSWDBBlockArgument >> simulateMessageSendToFinalField: aMessage [

	"Private - Attempt to simulate sending aMessage to the targetClass of the receiver's finalField.
	Only simulate messages implemented by and in directly-persisted non-base classes (e.g. implementations in Object are ignored).
	Return nil if no method is simulated, otherwise the result of the simulated send"

	| field targetClass reStoreValueMethod messages method |

	field := self peekFinalField.
	targetClass := field targetClass.
	targetClass isDirectlyPersistedNonBaseClass ifFalse: [^nil].

	method := targetClass lookupMethod: aMessage selector.
	(method isNil or: [method methodClass isDirectlyPersistedNonBaseClass not]) ifTrue: [^nil].

	"Check if aMessage is the sole message sent by the implementation of #reStoreValue - shortcut this to reStoreValue"
	reStoreValueMethod  := targetClass lookupMethod: #reStoreValue.
	reStoreValueMethod isNil ifTrue: [self parseError: '<1d> does not implement #reStoreValue' << targetClass].

	messages := reStoreValueMethod messages.
	(messages size = 1 and: [messages anyOne = aMessage selector]) ifTrue: 
		[field targetClass: targetClass reStoreValueClass.
		^self].

	^self simulateMethod: method withArguments: aMessage arguments
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> sqlAnd: anSQLCondition [

	"Only sent in case of an implicit '= true' expression (or an error)"
	
	^self implicitEqualsTrue sqlAnd: anSQLCondition
	
	
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> sqlAndWithCondition: anSQLCondition [

	"Only sent in case of an implicit '= true' expression (or an error)"
	
	^anSQLCondition sqlAnd: self implicitEqualsTrue
	
]

{ #category : 'parsing - internal' }
SSWDBBlockArgument >> sqlConditionFor: aMessage [

	| argument |

	"Check for a method in a non-base directly-persisted class"
	(self simulateMessageSendToFinalField: aMessage) ifNotNil: [ :result | ^result].

	argument := aMessage arguments first.
	(argument isKindOf: SSWDBBlockEvaluator) ifTrue: [argument := argument finalField].

	^self newCondition 
		field: self finalField 
		is: (SSWSQLOperator messageSelector: aMessage selector)
		to: argument
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> sqlOr: anSQLCondition [

	"Only sent in case of an implicit '= true' expression (or an error)"
	
	^self implicitEqualsTrue sqlOr: anSQLCondition
	
	
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> sqlOrWithCondition: anSQLCondition [

	"Only sent in case of an implicit '= true' expression (or an error)"
	
	^anSQLCondition sqlOr: self implicitEqualsTrue
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> writeSQLOn: aStream [

	"If the receiver has been sent this message,
	then the receiver did not finish parsing a block due to an implicit ' = true'.
	
	Complete the translation and forward to the resulting condition.
	Note we reinstate the finalField, since if this message has been received
	it will possibly be sent again - need to maintain the receiver's state"
	
	| field condition |
	
	field := self peekFinalField.
	condition := self implicitEqualsTrue.
	condition isNil ifFalse: [self finalField: field].
	
	^(condition ifNil: [self finalField]) writeSQLOn: aStream
]

{ #category : 'parsing - implicit true' }
SSWDBBlockArgument >> | aValue [

	"Sent in case of an implicit '= true' expression, or possibly Integer bit manipulation"

	^self implicitEqualsTrue 
		ifNil: [self doesNotUnderstand: (MessageSend receiver: self selector: #| argument: aValue)]
		ifNotNil: [ :result | result | aValue]
]
