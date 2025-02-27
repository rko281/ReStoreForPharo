Extension { #name : 'Boolean' }

{ #category : '*SSW ReStore SQL Entities' }
Boolean >> then: trueValue else: otherValue [

	"SQL control flow message; maps to a CASE statement.
	Really just here to prevent unimplemented selector warnings but can be used where image/database agnostic code is needed"

	^self ifTrue: [trueValue] ifFalse: [otherValue]
]

{ #category : '*SSW ReStore SQL Entities' }
Boolean class >> writeSQLTypeOn: aStream using: anSQLDialect [

	aStream nextPutAll: anSQLDialect boolean
]
