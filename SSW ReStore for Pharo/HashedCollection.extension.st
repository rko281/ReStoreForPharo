Extension { #name : #HashedCollection }

{ #category : #'*SSW ReStore for Pharo' }
HashedCollection >> staticCollectionSpecClass [

	"Return the class of static collection spec that is appropriate for this kind of collection.
	Subclasses for which this may differ depending on mode of use should not implement this,
	but should route configuration through of:specClass: "

	^SSWDBHashedStaticCollectionSpec
]
