Extension { #name : 'String' }

{ #category : '*SSW ReStore for Pharo' }
String >> asParameterColumn [

	^SSWDBColAttr forString: self
]

{ #category : '*SSW ReStore for Pharo' }
String class >> instanceFromDBValue: aValue in: anSSWReStore [

	"ASSERT: aValue isNil OR aValue isKindOf: self"

	^aValue
]
