"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionBlockReceiver,
	#superclass : #SSWDBBlockEvaluator,
	#instVars : [
		'collectionSpec',
		'collection',
		'currentMode'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #'parsing-comparisons' }
SSWDBCollectionBlockReceiver >> <= aValue [

	self validateSizeMode.

	^self conditionWithAggregatedQuery: (self localSelectQueryFrom: [ :each | each count <= aValue])
]

{ #category : #'parsing-comparisons' }
SSWDBCollectionBlockReceiver >> = aValue [

	self validateSizeMode.

	^aValue = 0
		ifTrue: [self isEmpty]
		ifFalse: [self conditionWithAggregatedQuery: (self localSelectQueryFrom: [ :each | each count = aValue])]
]

{ #category : #'parsing-comparisons' }
SSWDBCollectionBlockReceiver >> > aValue [

	self validateSizeMode.

	^self conditionWithAggregatedQuery: (self localSelectQueryFrom: [ :each | each count > aValue])
]

{ #category : #'parsing-comparisons' }
SSWDBCollectionBlockReceiver >> >= aValue [

	self validateSizeMode.

	^self conditionWithAggregatedQuery: (self localSelectQueryFrom: [ :each | each count >= aValue])
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> anySatisfy: aBlock [

	"Return an appropriate subquery condition"

	self resetCurrentMode.

	^self conditionWithQuery: 
		((self selectQueryFrom: aBlock)
			fields: self targetField;
			yourself)
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> collection [

	^collection ifNil: [collection := self reStore instancesOf: self collectionSpec targetClass]
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> collectionParser [

	^self collection parser
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> collectionSpec [
	^collectionSpec
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> collectionSpec: anObject [
	collectionSpec := anObject
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> conditionWithAggregatedQuery: aQuery [

	^self conditionWithQuery:
		(aQuery asAggregatedQuery
			fields: self targetFieldCollectQuery fields;
			groupByFields: self targetFieldCollectQuery fields;
			yourself)
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> conditionWithQuery: aQuery [

	^self newCondition 
		field: self collectionSpec table idField 
		is: (SSWSQLOperator messageSelector: #includedIn:)
		to: aQuery asSubQuery
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> currentMode [

	"currentMode stores a Symbol indicating the mode in which the next message send will be interpreted - this denotes any special handling of the next message.
	Should be reset to nil after each message is processed"

	^currentMode
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> currentMode: aSymbol [

	"currentMode stores a Symbol indicating the mode in which the next message send will be interpreted - this denotes any special handling of the next message.
	Should be reset to nil after each message is processed"

	currentMode := aSymbol
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> currentTable [

	self error: 'not appropriate'
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> finalField [

	self parser qualifyingConditions: self collectionParser qualifyingConditions.

	^self finalFieldFor: self targetTableFromParser
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> finalFieldFor: aTable [

	"Private - Derive a SQL function from the current mode"

	self currentMode = #size ifTrue: [^(SSWDBQueryTableField forField: aTable idField in: aTable) withFunction: (self reStore sqlDialect sqlFunctionFor: #count)].
	self currentMode = #first ifTrue: [^(SSWDBQueryIDField forTable: aTable) withFunction: (self reStore sqlDialect sqlFunctionFor: #minimum)].
	self currentMode = #last ifTrue: [^(SSWDBQueryIDField forTable: aTable) withFunction: (self reStore sqlDialect sqlFunctionFor: #maximum)].

	^self error: 'unknown function ', self currentMode
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> first [

	self currentMode: #first
]

{ #category : #testing }
SSWDBCollectionBlockReceiver >> hasFinalField [

	^#(#size #first #last) includes: self currentMode
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> includes: anObject [

	"Turn into an equivalent anySatisfy:"

	^self anySatisfy: [ :each | each _id = anObject]
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> includesAssociation: anAssociation [

	"For dictionaires - turn into an equivalent anySatisfy:"

	^self anySatisfy: [ :each | ((self collectionSpec keyAccessor value: each) = anAssociation key) & (each _id = anAssociation value)]
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> includesKey: anObject [

	"For dictionaires - turn into an equivalent anySatisfy:"

	^self anySatisfy: [ :each | (self collectionSpec keyAccessor value: each) = anObject]
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> isEmpty [

	"Return an appropriate subquery condition"

	self resetCurrentMode.

	^self newCondition 
		field: self collectionSpec table idField 
		is: ((SSWSQLOperator messageSelector: #includedIn:) invert; yourself)
		to: self targetFieldCollectQuery asSubQuery
]

{ #category : #testing }
SSWDBCollectionBlockReceiver >> isKindOf: aClass [ 

	"Overriden due to 'odd' behaviour of #class in the receiver"

	^(Array 
		with: SSWDBCollectionBlockReceiver
		with: SSWDBGeneralCollectionBlockReceiver
		with: SSWDBOwnedCollectionBlockReceiver) includes: aClass
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> last [

	self currentMode: #last
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> localSelectQueryFrom: aOneArgBlock [

	"For subqueries on the collection which originate in the receiver only (hence the #local prefix) - this may have implications for subclasses"

	^self collectionParser selectQueryFrom: aOneArgBlock
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> qualifyCollectionParserWith: aBlock [

	self collectionParser qualifyWith: aBlock
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> resetCurrentMode [

	self currentMode: nil
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> select: aBlock [

	"Qualify the targerParser for further processing"

	self resetCurrentMode.

	self qualifyCollectionParserWith: aBlock.

	^self
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> selectQueryFrom: aOneArgBlock [

	"For subqueries on the collection, e.g. [ :person | person orders select: [ :each | ...]] - the latter block is the subquery block"

	^self collectionParser selectQueryFrom: aOneArgBlock
]

{ #category : #'parsing-collection messages' }
SSWDBCollectionBlockReceiver >> size [

	self currentMode: #size
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> targetField [

	"Return the field which represents the target object of (actual member of) the collection"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> targetFieldCollectQuery [

	"Return a collect: query for returning the target field from the collection"

	^self subclassResponsibility
]

{ #category : #accessing }
SSWDBCollectionBlockReceiver >> targetTableFromParser [

	"Ensure the target collection table is included in the parser.
	Return the table, aliased if necessary"

	^self subclassResponsibility
]

{ #category : #helpers }
SSWDBCollectionBlockReceiver >> validateSizeMode [

	self currentMode = #size ifFalse: [self error: 'comparison message received when not in #size mode'].
	self resetCurrentMode
]

{ #category : #'parsing-comparisons' }
SSWDBCollectionBlockReceiver >> ~= aValue [

	self validateSizeMode.

	^self conditionWithAggregatedQuery: (self localSelectQueryFrom: [ :each | each count ~= aValue])
]
