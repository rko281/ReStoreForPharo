Extension { #name : #SSWReStoreSortTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreSortTest >> isExpectedFailure [ 

	"Block variants not supported on Pharo"

	^super isExpectedFailure or: [ '*WithBlocks*' match: self selector ]
]
