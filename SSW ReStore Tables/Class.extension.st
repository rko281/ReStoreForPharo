Extension { #name : 'Class' }

{ #category : '*SSW ReStore Tables' }
Class >> defineAs: aSymbol in: anSSWDBTable [

	"The receiver has been specified as the kind of object held in inst var named aSymbol
	for the class whose DB table is anSSWDBTable.

	Add the receiver to anSSWDBTable returning the object created"

	^anSSWDBTable define: aSymbol asInstVarHolding: self
]

{ #category : '*SSW ReStore Tables' }
Class >> inlined [

	^SSWDBInlinedClass new
		inlinedClass: self;
		yourself
]
