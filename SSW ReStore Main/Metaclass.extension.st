Extension { #name : #Metaclass }

{ #category : #'*SSW ReStore Main' }
Metaclass class >> instanceFromDBValue: aValue in: anSSWReStore [

	"Classes are represented by name"
	
	^aValue ifNotNil: [ :clsName | self class environment at: clsName asSymbol ifAbsent: [self error: 'Class not in image']]
]
