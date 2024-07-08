Extension { #name : 'SSWSQLDialect' }

{ #category : '*SSW ReStore Tables' }
SSWSQLDialect >> instVarAccessorFor: aClass [

	"Create and return an inst var accessor (instance of SSWInstVarAccessor or subclass)
	appropriate for accessing an inst var holding an instance of the the given class"

	"Special cases"
	((aClass includesBehavior: String) and: [self shouldMapEmptyStringsToNil]) ifTrue: 
		[^SSWTransformingInstVarAccessor newWithTransformation: (Message selector: #orNilIfEmpty)].

	"Default"
	^SSWInstVarAccessor new
]
