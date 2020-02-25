Extension { #name : #SSWDBByteArrayWithInfo }

{ #category : #'*SSW ReStore SQL Entities' }
SSWDBByteArrayWithInfo >> writeSQLTypeOn: aStream using: anSQLDialect [

	aStream nextPutAll: ((anSQLDialect blobTypeForSize: self fieldSize) expandMacrosWith: self fieldSize)
]
