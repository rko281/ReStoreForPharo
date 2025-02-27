Extension { #name : 'String' }

{ #category : '*SSW ReStore Tables' }
String class >> reStoreInstVarAccessorIn: aSQLDialect [

	"Return a new inst var accessor to be used to access instances of this class in another object, in aSQLDialect"

	^aSQLDialect shouldMapEmptyStringsToNil 
		ifTrue: [SSWTransformingInstVarAccessor newWithTransformation: (Message selector: #orNilIfEmpty)]
		ifFalse: [super reStoreInstVarAccessorIn: aSQLDialect]
]
