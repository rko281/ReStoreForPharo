Extension { #name : #SortedCollection }

{ #category : #'*Wolphin' }
SortedCollection class >> defaultSortBlock [ 
	^[ :a :b | a <= b]
]

{ #category : #'*Wolphin' }
SortedCollection class >> value: a value: b [

	^a <= b
]
