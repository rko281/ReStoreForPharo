Extension { #name : 'SSWDBField' }

{ #category : '*SSW ReStore for Pharo' }
SSWDBField >> columnIn: anODBCConnection [

	^(anODBCConnection columnsInTable: self table) at: self
]
