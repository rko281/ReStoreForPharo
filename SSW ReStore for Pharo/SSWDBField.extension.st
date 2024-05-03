Extension { #name : 'SSWDBField' }

{ #category : '*SSW ReStore for Pharo' }
SSWDBField >> asParameterColumn: anInteger for: aStatement [

	^self columnIn: aStatement parent
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBField >> columnIn: anODBCConnection [

	^(anODBCConnection columnsInTable: self table) at: self
]
