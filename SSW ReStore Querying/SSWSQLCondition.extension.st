Extension { #name : 'SSWSQLCondition' }

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> convertValue: aValue [

	"For situations where a condition is being used as a result field in a query.
	Since the receiver is a condition, its result must be a Boolean"

	^Boolean instanceFromDBValue: aValue in: self reStore
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> fieldNamed: aString [

	"Polymorphic with SSWDBField; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^self field fieldNamed: aString
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> finalField [

	"Polymorphic with SSWDBBlockEvaluator; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^self
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> hasFinalField [

	"Polymorphic with SSWDBBlockEvaluator; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^true
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> reStore [

	^self field reStore
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> requiresAliasing [

	"Polymorphic with SSWDBField; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^false
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> table [

	"Polymorphic with SSWDBField; used when collect: queries have a condition as a result field, e.g. object cancelDate notNil"

	^self field table
]

{ #category : '*SSW ReStore Querying' }
SSWSQLCondition >> writeAliasedSQLOn: aStream [

	"For situations where a condition is being used as a result field in a query"

	aStream nextPutAliasedField: self
]
