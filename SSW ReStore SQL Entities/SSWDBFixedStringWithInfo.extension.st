Extension { #name : 'SSWDBFixedStringWithInfo' }

{ #category : '*SSW ReStore SQL Entities' }
SSWDBFixedStringWithInfo >> writeSQLTypeOn: aStream using: anSQLDialect [

	"If the receiver's size exceeds the maximum allowed, use a longText (if available)"

	(self fieldSize > anSQLDialect maxChar)
		ifTrue: [aStream nextPutAll: (anSQLDialect unsizedStringTypeForSize: self fieldSize)]
		ifFalse: [aStream nextPutAll: (anSQLDialect char expandMacrosWith: self fieldSize)]
]
