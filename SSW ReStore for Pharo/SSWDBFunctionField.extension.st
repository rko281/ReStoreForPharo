Extension { #name : 'SSWDBFunctionField' }

{ #category : '*SSW ReStore for Pharo' }
SSWDBFunctionField >> asParameterColumn: anInteger for: aStatement [

	^(super asParameterColumn: anInteger for: aStatement)
		isFunctionParameter: true;
		yourself
]
