Extension { #name : 'True' }

{ #category : '*SSW ReStore SQL Entities' }
True >> asSQLStringIn: aSQLDialect [

	"ASSERT: trueObject is a String in this dialect"
	^aSQLDialect trueObject
]
