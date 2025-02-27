Class {
	#name : 'SSWMySQLRow',
	#superclass : 'MySQLBinaryRowData',
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'accessing' }
SSWMySQLRow >> columnNames [

	^columnDescriptors collect: [ :each | each name ]
]

{ #category : 'accessing' }
SSWMySQLRow >> data [

	^columnValues
]

{ #category : 'accessing' }
SSWMySQLRow >> data: aCollection [

	columnValues := aCollection
]

{ #category : 'accessing' }
SSWMySQLRow >> first [

	^self atIndex: 1
]

{ #category : 'reading' }
SSWMySQLRow >> readColumnFrom: aStream perDescrption: columnDescr [
	| reader type value mask |

	reader := MySQLBinaryReader default.
	type := columnDescr type.
	type = MySQLTypes typeTINY ifTrue: [mask := 16r80. value := reader tinyIntFrom: aStream].
	type = MySQLTypes typeSHORT ifTrue: [mask := 16r8000. value := reader smallIntFrom: aStream].
	type = MySQLTypes typeINT24 ifTrue: [mask := 16r80000000. value := reader mediumIntFrom: aStream].	
	type = MySQLTypes typeLONG ifTrue: [mask := 16r80000000. value := reader longIntFrom: aStream].	
	type = MySQLTypes typeLONGLONG ifTrue: [mask := 16r8000000000000000. value := reader bigIntFrom: aStream].

	value notNil ifTrue: 
		[^(columnDescr isUnsigned or: [(value bitAnd: mask) = 0]) 
			ifTrue: [value]
			ifFalse: [value - (mask << 1) "if msb is set and field is signed, then negative"]].
	
	(type = MySQLTypes typeSTRING or: [type = MySQLTypes typeVARCHAR or: [type = MySQLTypes typeVARSTRING]]) ifTrue: [^columnDescr stringOrByteArrayFrom: (reader varBlobFrom: aStream)].

	type = MySQLTypes typeFLOAT ifTrue: [^reader floatFrom: aStream].
	type = MySQLTypes typeDOUBLE ifTrue: [^reader doubleFrom: aStream].
	(type = MySQLTypes typeDECIMAL or: [type = MySQLTypes typeNEWDECIMAL]) ifTrue: [^reader decimalWithScale: columnDescr decimals from: aStream].
	
	type = MySQLTypes typeTIME ifTrue: [^reader timeFrom: aStream].
	type = MySQLTypes typeDATE ifTrue: [^reader dateFrom: aStream].
	type = MySQLTypes typeDATETIME ifTrue: [^reader dateTimeFrom: aStream].
	type = MySQLTypes typeTIMESTAMP ifTrue: [^reader timeStampFrom: aStream].
	type = MySQLTypes typeYEAR ifTrue: [^reader yearFrom: aStream].
	
	(type = MySQLTypes typeTINYBLOB or: [type = MySQLTypes typeBLOB or: [type = MySQLTypes typeMEDIUMBLOB or: [type = MySQLTypes typeLONGBLOB]]]) ifTrue: [^columnDescr stringOrByteArrayFrom: (reader varBlobFrom: aStream)].

	self error: 'Unknown mysql type'
]
