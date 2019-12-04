Extension { #name : #SSWDBRelatedWrapper }

{ #category : #'*SSW ReStore Collections' }
SSWDBRelatedWrapper >> beKeyClassOf: aTableComponent [

	"Polymorphic with the Class implementation"

	self relatedObject beKeyClassOf: aTableComponent.
	aTableComponent beKeyRelated
]

{ #category : #'*SSW ReStore Collections' }
SSWDBRelatedWrapper >> beTargetClassOf: aTableComponent [

	"Polymorphic with the Class implementation"

	self relatedObject beTargetClassOf: aTableComponent.
	aTableComponent beValueRelated
]
