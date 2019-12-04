Extension { #name : #Dictionary }

{ #category : #'*Wolphin' }
Dictionary class >> withAll: aCollectionOfAssociations [

	| new |
	
	new := Dictionary new: aCollectionOfAssociations size // 2.
	aCollectionOfAssociations do: [ :each | new at: each key put: each value ].
	^new
]
