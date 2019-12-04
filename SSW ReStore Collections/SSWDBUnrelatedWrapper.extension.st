Extension { #name : #SSWDBUnrelatedWrapper }

{ #category : #'*SSW ReStore Collections' }
SSWDBUnrelatedWrapper >> beKeyClassOf: aTableComponent [

	"Polymorphic with the Class implementation"

	self unrelatedObject beKeyClassOf: aTableComponent.
	aTableComponent beKeyUnrelated
]

{ #category : #'*SSW ReStore Collections' }
SSWDBUnrelatedWrapper >> beTargetClassOf: aTableComponent [

	"Polymorphic with the Class implementation"

	self unrelatedObject beTargetClassOf: aTableComponent.
	aTableComponent beValueUnrelated
]
