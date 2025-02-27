Extension { #name : 'SSWDBDependentWrapper' }

{ #category : '*SSW ReStore Collections' }
SSWDBDependentWrapper >> beKeyClassOf: aTableComponent [

	"Polymorphic with the Class implementation"
		
	super beKeyClassOf: aTableComponent.
	aTableComponent beKeyDependent
]

{ #category : '*SSW ReStore Collections' }
SSWDBDependentWrapper >> beTargetClassOf: aTableComponent [

	"Polymorphic with the Class implementation"

	super beTargetClassOf: aTableComponent.
	aTableComponent beValueDependent
]
