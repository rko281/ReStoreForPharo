Extension { #name : #SSWReStoreIsNilQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreIsNilQueryTest >> expectedFailures [

	"testIsNilOrCondition fails due to complex or: block"

	^super expectedFailures, #(#testIsNilOrCondition)
]
