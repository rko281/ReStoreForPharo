Extension { #name : #SSWDBClassWithInfo }

{ #category : #'*SSW ReStore Tables' }
SSWDBClassWithInfo >> defineAs: aSymbol in: anSSWDBTable [

	"The receiver has been specified as the kind of object held in inst var named aSymbol
	for the class whose DB table is anSSWDBTable.

	Add the receiver to anSSWDBTable returning the object created
	(the receiver is polymorphic with classes)"

	^anSSWDBTable define: aSymbol asInstVarHolding: self
]
