Extension { #name : #SSWReStoreQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreQueryTest >> expectedFailures [

	"testIncludesInQueryBlockEmptyCriteria fails due to block usage"

	^super expectedFailures, #(#testIncludesInQueryBlockEmptyCriteria)
]
