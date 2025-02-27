Extension { #name : 'SSWDBFunctionField' }

{ #category : '*SSW ReStore Querying' }
SSWDBFunctionField >> forConcatenation [

	^SSWDBQueryConditionCollection with: self
]
