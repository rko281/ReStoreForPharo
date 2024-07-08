Extension { #name : 'SequenceableCollection' }

{ #category : '*SSW ReStore Collections' }
SequenceableCollection >> isOrdered [

	^true

]

{ #category : '*SSW ReStore Collections' }
SequenceableCollection >> staticCollectionSpecClass [ 

	^SSWDBOrderedStaticCollectionSpec


]
