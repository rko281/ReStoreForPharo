Extension { #name : #SSWDBQueryConditionCollection }

{ #category : #'*SSW ReStore for Pharo' }
SSWDBQueryConditionCollection >> collect: aBlock [

	^(super collect: aBlock)
		parser: self parser;
		yourself
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBQueryConditionCollection >> copy [ 
	^super copy
		parser: self parser;
		yourself
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBQueryConditionCollection >> copyEmpty [

	^super copyEmpty
		parser: self parser;
		yourself
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBQueryConditionCollection >> copyEmpty: anInteger [
	
	^(super copyEmpty: anInteger)
		parser: self parser;
		yourself
]
