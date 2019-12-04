Extension { #name : #SSWDBGeneralCollectionSpec }

{ #category : #'*SSW ReStore Querying' }
SSWDBGeneralCollectionSpec >> dbBlockCollectionReceiver [

	"Return a block receiver object suitable for parsing (mainly) subqueries involving the receiver"

	^SSWDBGeneralCollectionBlockReceiver new
		collectionSpec: self;
		yourself
]
