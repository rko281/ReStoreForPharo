Extension { #name : #Object }

{ #category : #'*SSW ReStore ODBC' }
Object class >> dbMaxFieldSize [

	"Invoked here where the reStoreIDClass is string or binary-based. Pass on to the reStoreIDClass"

	^self reStoreIDClass dbMaxFieldSize
]
