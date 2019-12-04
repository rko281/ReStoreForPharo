"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLCondition,
	#superclass : #SSWSQLFieldValueConjunction,
	#instVars : [
		'operator'
	],
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #'instance creation' }
SSWSQLCondition class >> equals [

	^self new
		
]

{ #category : #'instance creation' }
SSWSQLCondition class >> field: anSSWDBField equalTo: aValue [

	^self new field: anSSWDBField equalTo: aValue
]

{ #category : #'instance creation' }
SSWSQLCondition class >> field: anSSWDBField is: anSSWSQLOperator to: aValue [

	^self new field: anSSWDBField is: anSSWSQLOperator to: aValue
]

{ #category : #'instance creation' }
SSWSQLCondition class >> field: anSSWDBField value: aValue [

	^self new field: anSSWDBField value: aValue
]

{ #category : #'instance creation' }
SSWSQLCondition class >> fieldOnly: anSSWDBField [

	^self new fieldOnly: anSSWDBField
]

{ #category : #evaluating }
SSWSQLCondition >> & aCondition [

	"Double-dispatch to handle unexpected arguments"

	^aCondition sqlAndWithCondition: self
]

{ #category : #comparing }
SSWSQLCondition >> = anSSWSQLCondition [

	"Class test necessary for when the receiver is used as a result field in a query - in this case the receiver may be compared to a DBField"
	^anSSWSQLCondition class = SSWSQLCondition and: [super = anSSWSQLCondition and: [self operator = anSSWSQLCondition operator]]
]

{ #category : #accessing }
SSWSQLCondition >> aggregatedConditions [

	^self hasAggregateFunction
		ifTrue: [self newCollection add: self; yourself]
		ifFalse: [self newCollection beAND]
]

{ #category : #'collection behavior' }
SSWSQLCondition >> anySatisfy: aBlock [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^aBlock value: self
]

{ #category : #evaluating }
SSWSQLCondition >> asFieldAssignment [

	^SSWSQLFieldAssignment field: self field value: self value
]

{ #category : #evaluating }
SSWSQLCondition >> asOrderingSpec [

	"Return the receiver as an OrderingSpec
	 - for this the value is ignored, as it is assumed to be equivalent to the field"

	^self operator orderingSpecFor: self field
]

{ #category : #testing }
SSWSQLCondition >> canInvertValue [

	^(self value == true or: [self value == false]) and: [self operator isEquality or: [self operator isInequality]]
]

{ #category : #'collection behavior' }
SSWSQLCondition >> collect: aBlock [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^Array with: (aBlock value: self)
]

{ #category : #'collection behavior' }
SSWSQLCondition >> do: aBlock [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^aBlock value: self
]

{ #category : #'initialize/release' }
SSWSQLCondition >> field: anSSWDBField equalTo: aValue [

	^self field: anSSWDBField is: SSWSQLOperator equals to: aValue
]

{ #category : #'initialize/release' }
SSWSQLCondition >> field: anSSWDBField is: anSSWSQLOperator to: aValue [

	^self
		field: anSSWDBField;
		operator: anSSWSQLOperator;
		value: aValue;
		yourself
]

{ #category : #'initialize/release' }
SSWSQLCondition >> field: anSSWDBField value: aValue [

	^self field: anSSWDBField is: SSWSQLOperator setValue to: aValue
]

{ #category : #'initialize/release' }
SSWSQLCondition >> fieldOnly: anSSWDBField [

	^self field: anSSWDBField is: nil to: nil
]

{ #category : #'collection behavior' }
SSWSQLCondition >> flattened [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^Array with: self
]

{ #category : #testing }
SSWSQLCondition >> hasAggregateFunction [

	^self field hasAggregateFunction
]

{ #category : #'collection behavior' }
SSWSQLCondition >> isEmpty [

	"Make the receiver polymorphic with an SQLConditionCollection"
	
	^false
]

{ #category : #testing }
SSWSQLCondition >> isFieldCollection [

	"Polymorphic with SQLConditionCollection"

	^false
]

{ #category : #testing }
SSWSQLCondition >> isFieldOnly [

	^self operator isNil and: [self value isNil]
]

{ #category : #accessing }
SSWSQLCondition >> newCollection [

	^SSWSQLConditionCollection new
]

{ #category : #evaluating }
SSWSQLCondition >> not [

	"No operator for an implicit true expression"
	self isFieldOnly 
	ifTrue: 
		[self field: (self field withFunction: 'NOT(%1)' asSQLFunction arguments: #())]
	ifFalse: 
		[self canInvertValue 
			ifTrue: [self value: self value not]
			ifFalse: [self operator invert]]
]

{ #category : #accessing }
SSWSQLCondition >> operator [

	"operator stores the comparison operation for this condition"
	
	^operator
]

{ #category : #accessing }
SSWSQLCondition >> operator: anSSWSQLOperator [

	"operator stores the comparison operation for this condition"
	
	operator := anSSWSQLOperator
]

{ #category : #evaluating }
SSWSQLCondition >> sqlAnd: aConditionOrCollection [

	"Return an SQLConditionCollection consisting of the receiver ANDed with the given
	SQLCondition or SQLConditionCollection (the two are polymorphic)"

	^aConditionOrCollection isEmpty
	ifTrue:
		[self]
	ifFalse:
		[self newCollection
			beAND;
			add: self;
			add: aConditionOrCollection;
			yourself]
]

{ #category : #evaluating }
SSWSQLCondition >> sqlAndWithCondition: aConditionOrCollection [

	"Double-despatch entry point"

	^aConditionOrCollection sqlAnd: self
]

{ #category : #evaluating }
SSWSQLCondition >> sqlOr: aConditionOrCollection [

	"Return an SQLConditionCollection consisting of the receiver ORed with the given
	SQLCondition or SQLConditionCollection (the two are polymorphic)"

	^self newCollection
		beOR;
		add: self;
		add: aConditionOrCollection;
		yourself
]

{ #category : #evaluating }
SSWSQLCondition >> sqlOrWithCondition: aConditionOrCollection [

	"Double-despatch entry point"

	^aConditionOrCollection sqlOr: self
]

{ #category : #accessing }
SSWSQLCondition >> unaggregatedConditions [

	^self hasAggregateFunction
		ifTrue: [self newCollection beAND]
		ifFalse: [self newCollection add: self; yourself]
]

{ #category : #output }
SSWSQLCondition >> writeConjunctionSQLOn: aStream [

	self operator writeSQLOn: aStream forTarget: self value
]

{ #category : #output }
SSWSQLCondition >> writeSQLOn: aStream [

	"Handle special cases"

	"1) Where there is no operator or value (implicit true)"
	self isFieldOnly ifTrue: [^self writeFieldSQLOn: aStream].

	"2) Empty IN condition"
	(self operator isIncludedIn and: [self value isEmpty]) ifTrue: 
		[^(self operator isInverted 
			ifTrue: [SSWSQLCondition field: self field equalTo: self field]
			ifFalse: [(SSWSQLCondition field: self field equalTo: self field) not]) writeSQLOn: aStream].

	^super writeSQLOn: aStream
]

{ #category : #output }
SSWSQLCondition >> writeValueSQLOn: aStream [

	self value writeSQLOn: aStream forCondition: self
]

{ #category : #evaluating }
SSWSQLCondition >> | aCondition [

	"Double-dispatch to handle unexpected arguments"

	^aCondition sqlOrWithCondition: self
]
