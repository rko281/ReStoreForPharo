Extension { #name : #String }

{ #category : #'*SSW ReStore UDBC SQLite' }
String >> asParameterColumn [

	^SSWDBCColAttr forString: self
]
