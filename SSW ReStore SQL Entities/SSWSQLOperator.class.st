"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLOperator',
	#superclass : 'Object',
	#instVars : [
		'sqlString',
		'messageSelector',
		'isInverted'
	],
	#classInstVars : [
		'messageSQLMap',
		'messageInverseSQLMap'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLOperator class >> equals [

	^self messageSelector: #=
]

{ #category : 'instance creation' }
SSWSQLOperator class >> greaterThan [
	
	^self messageSelector: #>

]

{ #category : 'utility' }
SSWSQLOperator class >> inverseSQLStringForMessage: aSymbol [

	"Return the SQL text equivalent to the inverse of the given Smalltalk message.
	NB - no fallback (c.f. sqlStringForMessage:); error if no inverse found"
	
	^self messageInverseSQLMap at: aSymbol ifAbsent: [self error: 'No inverse defined for this message']
]

{ #category : 'utility' }
SSWSQLOperator class >> messageForSQLString: aString [

	"Return the SQL text equivalent to the given Smalltalk message"
	
	^self messageSQLMap keyAtValue: aString asUppercase ifAbsent: [aString asSymbol]
]

{ #category : 'constants' }
SSWSQLOperator class >> messageInverseSQLMap [

	"Maps Smalltalk message selectors to the equivalent SQL text for the *inverse* of that operation"
	
	^messageInverseSQLMap ifNil: 
		[messageInverseSQLMap := 
			(IdentityDictionary new
				at: #=			put: '<>';
				at: #~=			put: '=';
				at: #<			put: '>=';
				at: #>			put: '<=';
				at: #>=			put: '<';
				at: #<=			put: '>';
				at: #like:			put: 'NOT LIKE';
				at: #includedIn: 		put: 'NOT IN';
				yourself)]
]

{ #category : 'constants' }
SSWSQLOperator class >> messageSQLMap [

	"Maps Smalltalk message selectors to equivalent SQL text.
	Absent selectors map to their String equivalent"
	
	^messageSQLMap ifNil: 
		[messageSQLMap := 
			(IdentityDictionary new
				at: #~=			put: '<>';
				at: #like:			put: 'LIKE';
				at: #includedIn: 	put: 'IN';
				at: #value: 		put: '=';
				yourself)]
]

{ #category : 'instance creation' }
SSWSQLOperator class >> messageSelector: aSymbol [

	^self new
		messageSelector: aSymbol;
		sqlString: (self sqlStringForMessage: aSymbol);
		yourself
]

{ #category : 'instance creation' }
SSWSQLOperator class >> new [

	^super new
		isInverted: false;
		yourself
]

{ #category : 'instance creation' }
SSWSQLOperator class >> setValue [

	^self messageSelector: #value:
]

{ #category : 'instance creation' }
SSWSQLOperator class >> sqlString: aString [

	^self new
		messageSelector: (self messageForSQLString: aString);
		sqlString: aString;
		yourself
]

{ #category : 'utility' }
SSWSQLOperator class >> sqlStringForMessage: aSymbol [

	"Return the SQL text equivalent to the given Smalltalk message"
	
	^self messageSQLMap at: aSymbol ifAbsent: [aSymbol asString]
]

{ #category : 'comparing' }
SSWSQLOperator >> = anSSWSQLOperator [

	anSSWSQLOperator isNil ifTrue: [^false].

	^(self messageSelector = anSSWSQLOperator messageSelector) and:
		[self isInverted = anSSWSQLOperator isInverted]
]

{ #category : 'comparing' }
SSWSQLOperator >> compare: value1 with: value2 [

	| result |
	
	result := value1 perform: self messageSelector with: value2.
	
	^self isInverted
		ifTrue: [result not]
		ifFalse: [result]
]

{ #category : 'comparing' }
SSWSQLOperator >> hash [

	^self messageSelector hash
]

{ #category : 'modifying' }
SSWSQLOperator >> invert [

	self isInverted
	ifTrue: 
		[self sqlString: (self class sqlStringForMessage: self messageSelector).
		self isInverted: false]
	ifFalse: 
		[self sqlString: (self class inverseSQLStringForMessage: self messageSelector).
		self isInverted: true]

]

{ #category : 'testing' }
SSWSQLOperator >> isEquality [

	^self messageSelector = #= and: [self isInverted not]
]

{ #category : 'testing' }
SSWSQLOperator >> isIncludedIn [

	^self messageSelector = #includedIn:
]

{ #category : 'testing' }
SSWSQLOperator >> isInequality [

	^self messageSelector = #~= and: [self isInverted not]
]

{ #category : 'accessing' }
SSWSQLOperator >> isInverted [

	"isInverted stores a Boolean indicating whether the receiver should invert
	its result following a compare:with:.
	NB If the receiver isInverted, then its message selector will be *un*inverted,
	but the sqlString *will* be inverted. e.g.
		isInverted - false; messageSelector: #like:, sqlString: 'LIKE'
		isInverted - true; messageSelector: #like:, sqlString: 'NOT LIKE'	"
		
	^isInverted
]

{ #category : 'accessing' }
SSWSQLOperator >> isInverted: aBoolean [

	"isInverted stores a Boolean indicating whether the receiver should invert
	its result following a compare:with:.
	NB If the receiver isInverted, then its message selector will be *un*inverted,
	but the sqlString *will* be inverted. e.g.
		isInverted - false; messageSelector: #like:, sqlString: 'LIKE'
		isInverted - true; messageSelector: #like:, sqlString: 'NOT LIKE'	"
		
	isInverted := aBoolean
]

{ #category : 'testing' }
SSWSQLOperator >> isSetValue [

	"If the receiver is being used to set a value (rather than compare), 
	then #value: is the messageSelector, '=' is the sqlString.
	
	This is needed to as messageSelector #= is mapped to ' IS ' when used with NULL"
	
	^self messageSelector == #value:
]

{ #category : 'testing' }
SSWSQLOperator >> isValidForOrdering [

	^#(#< #<= #>= #>) includes: self messageSelector
]

{ #category : 'accessing' }
SSWSQLOperator >> messageSelector [

	"messageSelector stores the Smalltalk message name which is equivalent to the receiver's sqlString"
	
	^messageSelector
]

{ #category : 'accessing' }
SSWSQLOperator >> messageSelector: aSymbol [

	"messageSelector stores the Smalltalk message name which is equivalent to the receiver's sqlString"
	
	messageSelector := aSymbol
]

{ #category : 'testing' }
SSWSQLOperator >> orderingSpecFor: anObject [

	self isValidForOrdering ifFalse: [self error: 'Condition invalid for ordering'].

	^self isInverted
	ifTrue:
		[(self messageSelector first = $>)
			ifTrue: [SSWDBOrderingSpec ascending: anObject]
			ifFalse: [SSWDBOrderingSpec descending: anObject]]
	ifFalse:
		[(self messageSelector first = $<)
			ifTrue: [SSWDBOrderingSpec ascending: anObject]
			ifFalse: [SSWDBOrderingSpec descending: anObject]]
]

{ #category : 'accessing' }
SSWSQLOperator >> sqlString [

	"sqlString stores the SQL text for this operator"
	
	^sqlString
]

{ #category : 'accessing' }
SSWSQLOperator >> sqlString: aString [

	"sqlString stores the SQL text for this operator"
	
	sqlString := aString
]

{ #category : 'output' }
SSWSQLOperator >> sqlStringFor: aTargetValue [

	"aTargetValue is necessary as some SQL operators change form depending on the target value (e.g. IS NULL)"
	
	^(aTargetValue isSQLNull and: [self isSetValue not])
	ifTrue:
		[self sqlString = '=' 
		ifTrue: 
			['IS']
		ifFalse:
			[self sqlString = '<>'
				ifTrue: ['IS NOT']
				ifFalse: [self error: 'Invalid operator for nil']]]
	ifFalse:
		[self sqlString]
]

{ #category : 'output' }
SSWSQLOperator >> writeSQLOn: aStream forTarget: aTargetValue [

	"aTargetValue is necessary as some SQL operators change form 
	depending on the target value (e.g. IS NULL)"
	
	aStream nextPutAll: (self sqlStringFor: aTargetValue)
]
