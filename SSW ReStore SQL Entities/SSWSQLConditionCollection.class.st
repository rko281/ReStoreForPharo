"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLConditionCollection,
	#superclass : #SSWSQLCollection,
	#type : #variable,
	#instVars : [
		'sqlConcatenator'
	],
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #utility }
SSWSQLConditionCollection class >> concatenatorForAND [

	^' AND '
]

{ #category : #utility }
SSWSQLConditionCollection class >> concatenatorForOR [

	^' OR '
]

{ #category : #'instance creation' }
SSWSQLConditionCollection class >> forAND [

	^self new
		beAND;
		yourself
]

{ #category : #'instance creation' }
SSWSQLConditionCollection class >> forOR [
	
	^self new
		beOR;
		yourself
]

{ #category : #evaluating }
SSWSQLConditionCollection >> & aCondition [

	"Double-dispatch to handle unexpected arguments"

	^aCondition sqlAndWithCondition: self
]

{ #category : #'adding/removing' }
SSWSQLConditionCollection >> _add: aConditionOrCollection [

	"Bypass the automerge of add:"

	^super add: aConditionOrCollection
]

{ #category : #'adding/removing' }
SSWSQLConditionCollection >> add: aConditionOrCollection [

	"If the operand is another collection with the same concatenator, the receiver can merge with it"
	
	((aConditionOrCollection isKindOf: SSWSQLConditionCollection)
		and: [aConditionOrCollection sqlConcatenator = self sqlConcatenator])
			ifTrue: [self addAll: aConditionOrCollection]
			ifFalse: [self _add: aConditionOrCollection]
]

{ #category : #accessing }
SSWSQLConditionCollection >> aggregatedConditions [

	"Assumes aggregates are in top level only"

	^self select: [ :each | each hasAggregateFunction]

]

{ #category : #enumerating }
SSWSQLConditionCollection >> anySatisfy: aBlock [

	"Recursive version needed since the receiver will hold conditions or other condition collections"

	self do: [ :each | (each anySatisfy: aBlock) ifTrue: [^true]].

	^false
]

{ #category : #evaluating }
SSWSQLConditionCollection >> asFieldAssignment [

	"Polymorphic with SQLCondition implementation"

	| assignment |

	assignment := SSWSQLFieldAssignmentCollection new: self size.

	self do:
		[ :condition |
		assignment add: condition asFieldAssignment].

	^assignment

]

{ #category : #initializing }
SSWSQLConditionCollection >> beAND [

	self sqlConcatenator: self class concatenatorForAND
]

{ #category : #initializing }
SSWSQLConditionCollection >> beOR [

	self sqlConcatenator: self class concatenatorForOR
]

{ #category : #evaluating }
SSWSQLConditionCollection >> copy [

	^super copy
		sqlConcatenator: self sqlConcatenator;
		yourself
]

{ #category : #copying }
SSWSQLConditionCollection >> copyEmpty: anInteger [

	^(super copyEmpty: anInteger)
		sqlConcatenator: self sqlConcatenator;
		yourself

]

{ #category : #evaluating }
SSWSQLConditionCollection >> flattened [

	"Return a flat collection of the receiver's conditions.
	NB privileged clients only - the flattened variant has a changed meaning to the receiver"

	| flattened |

	flattened := OrderedCollection new.
	self do: [ :each | flattened addAll: each flattened].

	^flattened
]

{ #category : #testing }
SSWSQLConditionCollection >> hasAggregateFunction [

	^self anySatisfy: [:each | each hasAggregateFunction]
]

{ #category : #testing }
SSWSQLConditionCollection >> isAND [

	^self sqlConcatenator = self class concatenatorForAND
]

{ #category : #testing }
SSWSQLConditionCollection >> isEmpty [

	"Account for a collection of empty collections"
	
	^super isEmpty or: [self allSatisfy: [ :each | each isEmpty]]
]

{ #category : #testing }
SSWSQLConditionCollection >> isOR [

	^self sqlConcatenator = self class concatenatorForOR
]

{ #category : #evaluating }
SSWSQLConditionCollection >> not [

	"Invert the receiver
	 - ANDs become ORs (and v.v.)
	 - individual conditions are inverted"
	
	self isAND 
		ifTrue: [self sqlConcatenator: self class concatenatorForOR]
		ifFalse: [self sqlConcatenator: self class concatenatorForAND].
		
	self do: [ :condition | condition not].
	
	^self
]

{ #category : #evaluating }
SSWSQLConditionCollection >> sqlAnd: aConditionOrCollection [

	"Return an SQLConditionCollection consisting of the receiver ANDed with the given
	SQLCondition or SQLConditionCollection (the two are polymorphic)"

	aConditionOrCollection isEmpty ifTrue: [^self].

	^self copyEmpty beAND
		add: self;
		add: aConditionOrCollection;
		yourself
]

{ #category : #evaluating }
SSWSQLConditionCollection >> sqlAndWithCondition: aConditionOrCollection [

	"Double-despatch entry point"

	^aConditionOrCollection sqlAnd: self
]

{ #category : #accessing }
SSWSQLConditionCollection >> sqlConcatenator [

	"sqlConcatenator stores the String which merges these conditions 
	 - usually AND or OR"
	
	^sqlConcatenator
]

{ #category : #accessing }
SSWSQLConditionCollection >> sqlConcatenator: aString [

	"sqlConcatenator stores the String which merges these conditions 
	 - usually AND or OR"
	
	sqlConcatenator := aString
]

{ #category : #evaluating }
SSWSQLConditionCollection >> sqlOr: aConditionOrCollection [

	"Return an SQLConditionCollection consisting of the receiver ORed with the given
	SQLCondition or SQLConditionCollection (the two are polymorphic)"

	^self copyEmpty beOR
		add: self;
		add: aConditionOrCollection;
		yourself
]

{ #category : #evaluating }
SSWSQLConditionCollection >> sqlOrWithCondition: aConditionOrCollection [

	"Double-despatch entry point"

	^aConditionOrCollection sqlOr: self
]

{ #category : #accessing }
SSWSQLConditionCollection >> unaggregatedConditions [

	"Assumes aggregates are in top level only"

	^self reject: [ :each | each hasAggregateFunction]

]

{ #category : #output }
SSWSQLConditionCollection >> writeSQLOn: aStream [

	"Wrap in parantheses"
	
	aStream nextPut: $(.
	super writeSQLOn: aStream.
	aStream nextPut: $)
]

{ #category : #evaluating }
SSWSQLConditionCollection >> | aCondition [

	"Double-dispatch to handle unexpected arguments"

	^aCondition sqlOrWithCondition: self
]
