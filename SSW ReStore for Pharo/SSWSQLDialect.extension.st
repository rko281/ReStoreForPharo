Extension { #name : 'SSWSQLDialect' }

{ #category : '*SSW ReStore for Pharo' }
SSWSQLDialect >> platformSpecificFunctions [

	"Return a mapping from Smalltalk method names which are specific to this platform (Dolphin, Pharo...) to an equivalent SQL function in this dialect.
	Subclass implementations should be in the appropriate platform-specific package"

	^Dictionary new
]
