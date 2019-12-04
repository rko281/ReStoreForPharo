Extension { #name : #Metaclass }

{ #category : #'*SSW ReStore Main' }
Metaclass class >> instanceFromDBValue: aValue in: anSSWReStore [

	"Classes are represented by name"
	
	^aValue ifNotNil: [ :clsName | Smalltalk at: clsName asSymbol ifAbsent: [self error: 'Class not in image']]
]
