"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBQueryConditionCollection',
	#superclass : 'SSWSQLConditionCollection',
	#type : 'variable',
	#instVars : [
		'parser',
		'blockEndpoint',
		'postCondition'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'evaluating' }
SSWDBQueryConditionCollection >> _sqlAnd: aCondition [

	"Private - Bypass the local implementation"

	^super sqlAnd: aCondition
]

{ #category : 'evaluating' }
SSWDBQueryConditionCollection >> _sqlOr: aCondition [

	"Private - Bypass the local implementation"

	^super sqlOr: aCondition
]

{ #category : 'converting' }
SSWDBQueryConditionCollection >> asSQLConditions [

	"Convert the receiver to the standard non-query subsystem representation"

	| sql |

	sql := SSWSQLConditionCollection new: self size.
	sql sqlConcatenator: self sqlConcatenator.

	^self inject: sql into: [ :all :each | all add: each asSQLConditions; yourself]
]

{ #category : 'converting' }
SSWDBQueryConditionCollection >> asSQLFields [

	"Convert the receiver to the standard non-query subsystem representation for fields"

	"The receiver represents the concept of a result field which is a composite condition"
	^self size = 1 
		ifTrue: [self first asSQLFields] 
		ifFalse: [self asSQLConditions]
]

{ #category : 'accessing' }
SSWDBQueryConditionCollection >> blockEndpoint [
	^blockEndpoint
]

{ #category : 'accessing' }
SSWDBQueryConditionCollection >> blockEndpoint: anObject [
	blockEndpoint := anObject
]

{ #category : 'evaluating' }
SSWDBQueryConditionCollection >> concatenateCondition: aCondition [

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
SSWDBQueryConditionCollection >> concatenatedWith: anObject [

	"Private - Double-despatch entry point"

	^anObject concatenateCondition: self
]

{ #category : 'copying' }
SSWDBQueryConditionCollection >> copyLikeOfSize: anInteger [

	^(super copyLikeOfSize: anInteger)
		parser: self parser;
		yourself

]

{ #category : 'converting' }
SSWDBQueryConditionCollection >> forConcatenation [

	^true
]

{ #category : 'accessing' }
SSWDBQueryConditionCollection >> parser [
	^parser
]

{ #category : 'accessing' }
SSWDBQueryConditionCollection >> parser: anObject [
	parser := anObject
]

{ #category : 'accessing' }
SSWDBQueryConditionCollection >> postCondition [
	^postCondition
]

{ #category : 'accessing' }
SSWDBQueryConditionCollection >> postCondition: anObject [
	postCondition := anObject
]

{ #category : 'evaluating' }
SSWDBQueryConditionCollection >> sqlAnd: aCondition [

	| argument receiver |

	argument := self parser unprocessedConditionsCombinedWithArgument: aCondition.
	receiver := self parser unprocessedConditionsCombinedWithReceiver: self.

	^receiver _sqlAnd: argument
]

{ #category : 'evaluating' }
SSWDBQueryConditionCollection >> sqlOr: aCondition [

	| argument receiver |

	argument := self parser unprocessedConditionsCombinedWithArgument: aCondition.
	receiver := self parser unprocessedConditionsCombinedWithReceiver: self.

	^receiver _sqlOr: argument
]

{ #category : 'evaluating' }
SSWDBQueryConditionCollection >> || anObject [

	"Primarily for multi-field collect: and project: - concatenate with anObject, which may be aBlockEvaluator or another Condition(Collection).
	Polymorphic with SSWDBBlockEvaluator; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^anObject forConcatenation concatenatedWith: self
]
