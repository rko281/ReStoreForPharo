Extension { #name : #SSWReStoreBlockAndOrQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreBlockAndOrQueryTest >> expectedFailures [

	"Most fail in Pharo due to incomplete handling of un-inlining of and: / or:"
	
	^super expectedFailures, #(#testBlockAndOrAndCombination #testBlockOr #testBlockOrAndCombination #testBlockOrNonBlockAndCombination #testMixBlockNonBlockAndOrCombinations)
]
