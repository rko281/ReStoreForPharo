Extension { #name : #Class }

{ #category : #'*SSW ReStore Collections' }
Class >> beKeyClassOf: aCollectionSpec [

	"The receiver has been specified as the class of objects which are the keys 
	of the collection specified by aCollectionSpec.
	Initialize aCollectionSpec accordingly"

	aCollectionSpec keyClass: self
]

{ #category : #'*SSW ReStore Collections' }
Class >> beTargetClassOf: aCollectionSpec [

	"The receiver has been specified as the class of objects held in 
	the collection specified by aCollectionSpec.
	Initialize aCollectionSpec accordingly"

	aCollectionSpec targetClass: self
]
