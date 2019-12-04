Extension { #name : #SSWReStoreImplicitTrueQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreImplicitTrueQueryTest >> expectedFailures [

	"Inlined variants not completely handled on Pharo"
	^super expectedFailures, #(#testInlinedAndFirst #testInlinedAndMid #testInlinedOrFirst #testInlinedOrMid) 
]
