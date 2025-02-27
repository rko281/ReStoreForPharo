Extension { #name : 'Boolean' }

{ #category : '*SSW ReStore Querying' }
Boolean >> asSQLConditions [

	"Received following a query block similar to [ :each | true]"

	"Always true = no conditions"
	^SSWSQLConditionCollection forAND
]
