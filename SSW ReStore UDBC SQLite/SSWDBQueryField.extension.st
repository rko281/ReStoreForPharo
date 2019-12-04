Extension { #name : #SSWDBQueryField }

{ #category : #'*SSW ReStore UDBC SQLite' }
SSWDBQueryField >> asParameterColumn: anInteger for: aStatement [

	^self field asParameterColumn: anInteger for: aStatement
]
