Extension { #name : #UndefinedObject }

{ #category : #'*SSW ReStore Querying' }
UndefinedObject >> isRequiredForSimilarity [

	"Private - nil (as in unset) not required for similarity. Use 'nil required' instead"

	^false
]

{ #category : #'*SSW ReStore Querying' }
UndefinedObject >> required [

	"Return the 'required nil' object"

	^RequiredUndefinedObject soleInstance
]
