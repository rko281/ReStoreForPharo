Extension { #name : #SSWReStoreBlockIfNilQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreBlockIfNilQueryTest class >> compiler [

	^ super compiler options: #(+ optionInlineNone)
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreBlockIfNilQueryTest >> isExpectedFailure [

	"We opt out of inlining ifNil: but testSelectSimpleObjectWithFunctionIfNil still fails due to ordering of match: and ifNil: evaluation (needs work)"

	^ self selector = #testSelectSimpleObjectWithFunctionIfNil or: [super isExpectedFailure] 
]
