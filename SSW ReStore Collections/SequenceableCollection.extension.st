Extension { #name : #SequenceableCollection }

{ #category : #'*SSW ReStore Collections' }
SequenceableCollection >> _collectionAdditions [

	"Reimplemented to include index (key) information"

	^self _keyedCollectionAdditions
]

{ #category : #'*SSW ReStore Collections' }
SequenceableCollection >> isOrdered [

	^true

]

{ #category : #'*SSW ReStore Collections' }
SequenceableCollection >> staticCollectionSpecClass [ 

	^SSWDBOrderedStaticCollectionSpec


]
