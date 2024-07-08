"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBQueryCondition',
	#superclass : 'SSWSQLCondition',
	#instVars : [
		'parser'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'evaluating' }
SSWDBQueryCondition >> _sqlAnd: aCondition [

	"Private - Bypass the local implementation"

	^super sqlAnd: aCondition
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> _sqlOr: aCondition [

	"Private - Bypass the local implementation"

	^super sqlOr: aCondition
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> addLast: anObject [

	"Received if the receiver is masquerading as a ConctenatedCollection"

	| collection |

	(collection := SSWDBQueryFieldCollection new)
		parser: self parser;
		add: collection; "<- will be self after become"
		add: (SSWSQLParameterField forValue: anObject);
		become: self
]

{ #category : 'converting' }
SSWDBQueryCondition >> asSQLConditions [

	"Convert the receiver to the standard non-query subsystem representation"

	^SSWSQLCondition field: self field is: self operator to: self value
]

{ #category : 'converting' }
SSWDBQueryCondition >> asSQLFields [

	"Convert the receiver to the standard non-query subsystem representation for fields"

	^self isFieldOnly 
		ifTrue: [self field]
		ifFalse: [self asSQLConditions]
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> concatenateCondition: aCondition [

	"Since the receiver is a condition and not a FieldCollection (the result of a concatenation), it must be the first condition in the concatenation"

	| argument receiver |

	argument := self parser unprocessedConditionsCombinedWithArgument: aCondition.
	receiver := self parser unprocessedConditionsCombinedWithReceiver: self.

	^SSWDBQueryFieldCollection new
		parser: self parser;
		add: receiver;
		add: argument;
		yourself
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> concatenatedWith: anObject [

	"Private - Double-despatch entry point"

	^anObject concatenateCondition: self
]

{ #category : 'parsing - internal' }
SSWDBQueryCondition >> doesNotUnderstand: aMessage [
	
	"Attempt to interpret selector as a function message send"
	(self table reStore sqlDialect sqlFunctionFor: aMessage selector) ifNotNil: 
		[ :function | 
		^self parser applyFunction: function to: self withArguments: aMessage arguments].

	^super doesNotUnderstand: aMessage
]

{ #category : 'converting' }
SSWDBQueryCondition >> forConcatenation [

	^self
]

{ #category : 'accessing' }
SSWDBQueryCondition >> newCollection [

	^self parser newConditionCollection
]

{ #category : 'accessing' }
SSWDBQueryCondition >> parser [
	^parser
]

{ #category : 'accessing' }
SSWDBQueryCondition >> parser: anObject [
	parser := anObject
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> sqlAnd: aCondition [

	| argument receiver |

	argument := self parser unprocessedConditionsCombinedWithArgument: aCondition.
	receiver := self parser unprocessedConditionsCombinedWithReceiver: self.

	^receiver _sqlAnd: argument
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> sqlOr: aCondition [

	| argument receiver |

	argument := self parser unprocessedConditionsCombinedWithArgument: aCondition.
	receiver := self parser unprocessedConditionsCombinedWithReceiver: self.

	^receiver _sqlOr: argument
]

{ #category : 'converting' }
SSWDBQueryCondition >> withFunction: aString arguments: aCollection [

	"Return an SSWDBFunctionField base on the receiver with the given function String and arguments"

	^SSWDBFunctionField new
		field: self;
		function: aString;
		arguments: aCollection;
		yourself
]

{ #category : 'evaluating' }
SSWDBQueryCondition >> || anObject [

	"Primarily for multi-field collect: and project: - concatenate with anObject, which may be aBlockEvaluator or another Condition"

	^anObject forConcatenation concatenatedWith: self
]
