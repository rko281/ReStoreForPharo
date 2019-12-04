Extension { #name : #SSWSQLJoinedTableCollection }

{ #category : #'*SSW ReStore for Pharo' }
SSWSQLJoinedTableCollection >> collect: aBlock [

	^(super collect: aBlock)
		joinConditions: self joinConditions copy;
		yourself
]
