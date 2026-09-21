Extension { #name : 'SSWDBFunctionField' }

{ #category : '*SSW ReStore ODBC' }
SSWDBFunctionField >> asParameterColumn: anInteger for: aStatement [

	^(super asParameterColumn: anInteger for: aStatement) copyForFunction
]
