Extension { #name : #SSWDBField }

{ #category : #'*SSW ReStore UDBC SQLite' }
SSWDBField >> asParameterColumn: anInteger for: aStatement [

	^self columnIn: aStatement parent
]

{ #category : #'*SSW ReStore UDBC SQLite' }
SSWDBField >> columnIn: anODBCConnection [

	^(anODBCConnection columnsInTable: self table) at: self
]
