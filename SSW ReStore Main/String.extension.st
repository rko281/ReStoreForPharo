Extension { #name : 'String' }

{ #category : '*SSW ReStore Main' }
String class >> instanceFromDBValue: aValue in: anSSWReStore [

	"ASSERT: aValue isNil OR aValue isKindOf: self"

	^aValue
]

{ #category : '*SSW ReStore Main' }
String >> withComponents [

	"Treat as an object, not a collection"

	^SSWDBObjectWithComponents on: self
]

{ #category : '*SSW ReStore Main' }
String >> withRelatedComponents [

	"Treat as an object, not a collection"

	^SSWDBObjectWithRelatedComponents on: self
]
