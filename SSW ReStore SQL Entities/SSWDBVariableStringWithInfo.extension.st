Extension { #name : #SSWDBVariableStringWithInfo }

{ #category : #'*SSW ReStore SQL Entities' }
SSWDBVariableStringWithInfo >> writeSQLTypeOn: aStream using: anSQLDialect [

	"If the receiver's size exceeds the maximum allowed, use a longText (if available)"

	(self fieldSize > anSQLDialect maxVarchar)
		ifTrue: [aStream nextPutAll: (anSQLDialect unsizedStringTypeForSize: self fieldSize)]
		ifFalse: [aStream nextPutAll: (anSQLDialect varchar expandMacrosWith: self fieldSize)]
]
