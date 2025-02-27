Extension { #name : 'SSWDBField' }

{ #category : '*SSW ReStore ODBC' }
SSWDBField >> asParameterColumn: anInteger for: aStatement [

	^self columnIn: aStatement parent
]
