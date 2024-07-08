Extension { #name : 'MySQLField' }

{ #category : '*SSW ReStore MySQL' }
MySQLField >> charSet [
	^ charSet
]

{ #category : '*SSW ReStore MySQL' }
MySQLField >> fieldName [

	^name
]

{ #category : '*SSW ReStore MySQL' }
MySQLField >> stringOrByteArrayFrom: aByteArray [

	"Handle
	1)	(Wide)Strings stored as UTF8 - for simplicity and consistency with Dolphin ODBC, Strings are stored as UTF8
	2) 	(var)chars/Strings appearing as blobs/ByteArrays:
		https://dev.mysql.com/doc/refman/8.0/en/c-api-data-structures.html
		'To distinguish between binary and nonbinary data for string data types, check whether the charsetnr value is 63. 
		If so, the character set is binary, which indicates binary rather than nonbinary data. 
		This enables you to distinguish BINARY from CHAR, VARBINARY from VARCHAR, and the BLOB types from the TEXT types.'	"

	^charSet = 63
		ifTrue: [aByteArray]
		ifFalse: [ZnUTF8Encoder default decodeBytesIntoWideString: aByteArray]
]
