Extension { #name : 'SSWDBQueryField' }

{ #category : '*SSW ReStore ODBC' }
SSWDBQueryField >> asParameterColumn: anInteger for: aStatement [

	^self field asParameterColumn: anInteger for: aStatement
]
