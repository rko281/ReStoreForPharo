Extension { #name : 'False' }

{ #category : '*SSW ReStore SQL Entities' }
False >> asSQLStringIn: aSQLDialect [

	"ASSERT: falseObject is a String in this dialect"
	^aSQLDialect falseObject
]
