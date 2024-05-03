Extension { #name : 'String' }

{ #category : '*SSW ReStore MySQL' }
String >> forSSWMySQL [

	"For simplicity and consistency with Dolphin, in ReStore Strings are stored in MySQL in UTF8 format"

	^ByteString withAll: (ZnUTF8Encoder default encodeString: self)
]
