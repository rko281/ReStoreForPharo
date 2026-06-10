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
