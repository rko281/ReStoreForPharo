Extension { #name : #String }

{ #category : #'*SSW ReStore for Pharo' }
String >> asParameterColumn [

	^SSWDBCColAttr forString: self
]
