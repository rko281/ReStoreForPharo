"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBBlockEvaluator,
	#superclass : #ProtoObject,
	#instVars : [
		'parser'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #'message sending' }
SSWDBBlockEvaluator >> chainPerform: aCollection [

	"perform: each member (Symbol) of aCollection against the receiver as a chain
	i.e. the second Symbol is perform:'d against the result of perform:ing the first, etc."

	^aCollection inject: self into: [ :receiver :symbol | receiver perform: symbol]

]

{ #category : #'parsing - functions' }
SSWDBBlockEvaluator >> concatenatedWith: aCollection [

	| queryCollection |

	(aCollection isKindOf: ConcatenatedCollection) 
		ifTrue: [queryCollection := (SSWDBQueryFieldCollection withAll: (aCollection collect: [ :each | SSWSQLParameterField forValue: each])) parser: self parser; yourself]
		ifFalse: [queryCollection := aCollection].

	^queryCollection concatenateCondition: self forConcatenation
]

{ #category : #accessing }
SSWDBBlockEvaluator >> currentTable [

	^self subclassResponsibility
]

{ #category : #testing }
SSWDBBlockEvaluator >> finalField [

	^self subclassResponsibility
]

{ #category : #converting }
SSWDBBlockEvaluator >> forConcatenation [

	"When received by an instance of this class, the current final field (rather than an actual condition) is being concatenated with another object, e.g. [ :person | person firstName || person surname]
	Return a corresponding field-only condition"

	^self parser newCondition 
		fieldOnly: 
			(self hasFinalField 
				ifTrue: [self finalField]
				ifFalse: [SSWDBQueryIDField forTable: self currentTable]);
		yourself
]

{ #category : #testing }
SSWDBBlockEvaluator >> hasFinalField [

	^self subclassResponsibility
]

{ #category : #helpers }
SSWDBBlockEvaluator >> imageDo: imageBlock databaseDo: databaseBlock [

	"Allow different code to be 'evaluated' depending on whether execution is in-image or 'in' the database (in the latter case code is not actually executed but converted to SQL)"

	^databaseBlock value
]

{ #category : #testing }
SSWDBBlockEvaluator >> isSimilarTo: anObject [

	^self perform: anObject similarityComparator with: anObject
]

{ #category : #accessing }
SSWDBBlockEvaluator >> newCondition [

	^self parser newCondition
]

{ #category : #accessing }
SSWDBBlockEvaluator >> parser [

	^parser
]

{ #category : #accessing }
SSWDBBlockEvaluator >> parser: anSSWDBBlockParser [

	parser := anSSWDBBlockParser
]

{ #category : #accessing }
SSWDBBlockEvaluator >> path [

	"The path of accessors form which this evaluator was created"

	^#()
]

{ #category : #accessing }
SSWDBBlockEvaluator >> reStore [

	"reStore stores the SSWReStore for which the receiver parses blocks"
	
	^self parser reStore
]

{ #category : #helpers }
SSWDBBlockEvaluator >> subclassResponsibility [

	"Private - Just here to prevent code warnings"

	^nil subclassResponsibility
]

{ #category : #'parsing - functions' }
SSWDBBlockEvaluator >> || aBlockEvaluatorOrCondition [

	"Concatenate with another block evaluator or condition (primarily for multi-field collect: and project:)"

	^(self parser unprocessedConditionsCombinedForConcatenation: aBlockEvaluatorOrCondition) concatenatedWith: self forConcatenation
]
