Extension { #name : 'SSWSQLConditionCollection' }

{ #category : '*SSW ReStore Querying' }
SSWSQLConditionCollection >> convertValue: aValue [

	"For situations where a condition is being used as a result field in a query.
	Since the receiver is a condition, its result must be a Boolean"

	^Boolean instanceFromDBValue: aValue in: self first field table reStore
]

{ #category : '*SSW ReStore Querying' }
SSWSQLConditionCollection >> fieldNamed: aString [

	"Polymorphic with SSWDBField; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^self 
]

{ #category : '*SSW ReStore Querying' }
SSWSQLConditionCollection >> finalField [

	"Polymorphic with SSWDBBlockEvaluator; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^self
]

{ #category : '*SSW ReStore Querying' }
SSWSQLConditionCollection >> hasFinalField [

	"Polymorphic with SSWDBBlockEvaluator; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^true
]

{ #category : '*SSW ReStore Querying' }
SSWSQLConditionCollection >> requiresAliasing [

	"Polymorphic with SSWDBField; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^false
]

{ #category : '*SSW ReStore Querying' }
SSWSQLConditionCollection >> writeAliasedSQLOn: aStream [

	"For situations where a condition is being used as a result field in a query"

	aStream nextPutAliasedField: self
]
