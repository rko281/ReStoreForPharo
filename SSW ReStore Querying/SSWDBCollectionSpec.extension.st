Extension { #name : 'SSWDBCollectionSpec' }

{ #category : '*SSW ReStore Querying' }
SSWDBCollectionSpec >> dbBlockCollectionReceiver [

	"Return a block receiver object suitable for parsing (mainly) subqueries involving the receiver"

	^self subclassResponsibility
]
