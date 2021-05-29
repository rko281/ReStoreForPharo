Class {
	#name : #SSWMySQLRow,
	#superclass : #MySQLBinaryRowData,
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#category : #'SSW ReStore MySQL'
}

{ #category : #accessing }
SSWMySQLRow >> columnNames [

	^columnDescriptors collect: [ :each | each name ]
]

{ #category : #accessing }
SSWMySQLRow >> columns: aCollection [

	columnDescriptors := aCollection
]

{ #category : #accessing }
SSWMySQLRow >> data [

	^columnValues
]

{ #category : #accessing }
SSWMySQLRow >> data: aCollection [

	columnValues := aCollection.
	
	"Handle
	1)
		(Wide)Strings stored as UTF8 - for simplicity and consistency with Dolphin, Strings are stored as UTF8
	2) (var)chars/Strings appearing as blobs/ByteArrays:
		https://dev.mysql.com/doc/refman/8.0/en/c-api-data-structures.html
		'To distinguish between binary and nonbinary data for string data types, check whether the charsetnr value is 63. 
		If so, the character set is binary, which indicates binary rather than nonbinary data. 
		This enables you to distinguish BINARY from CHAR, VARBINARY from VARCHAR, and the BLOB types from the TEXT types.'	"
	
	columnValues keysAndValuesDo:
		[ :index :value | 
		(value isKindOf: String) 
		ifTrue: 
			[ columnValues at: index put: (ZnUTF8Encoder default decodeBytesIntoWideString: value asByteArray) ]
		ifFalse: 
			[ ((value isKindOf: ByteArray) and: [ (columnDescriptors at: index) charSet ~= 63]) ifTrue: 
					[columnValues at: index put: (ZnUTF8Encoder default decodeBytesIntoWideString: value ) ] ] ]
]

{ #category : #accessing }
SSWMySQLRow >> first [

	^self atIndex: 1
]
