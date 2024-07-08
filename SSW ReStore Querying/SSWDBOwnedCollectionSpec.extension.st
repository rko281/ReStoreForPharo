Extension { #name : 'SSWDBOwnedCollectionSpec' }

{ #category : '*SSW ReStore Querying' }
SSWDBOwnedCollectionSpec >> dbBlockCollectionReceiver [

	"Return a block receiver object suitable for parsing (mainly) subqueries involving the receiver"

	^SSWDBOwnedCollectionBlockReceiver new
		collectionSpec: self;
		yourself
]
