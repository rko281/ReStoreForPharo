Extension { #name : 'String' }

{ #category : '*SSW ReStore Main' }
String >> isValidForPersistence [

	^true
]

{ #category : '*SSW ReStore Main' }
String >> reStoreValue [

	^self
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
