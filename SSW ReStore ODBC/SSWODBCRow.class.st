Class {
	#name : 'SSWODBCRow',
	#superclass : 'ODBCRow',
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#instVars : [
		'fieldMap'
	],
	#category : 'SSW ReStore ODBC',
	#package : 'SSW ReStore ODBC'
}

{ #category : 'accessing' }
SSWODBCRow >> data [

	^contents
]

{ #category : 'accessing' }
SSWODBCRow >> data: anObject [

	contents := anObject
]

{ #category : 'initializing' }
SSWODBCRow >> initializeFromBuffer: anSSWODBCBuffer [

	columns := anSSWODBCBuffer columns.
	contents := anSSWODBCBuffer objects.
	status := anSSWODBCBuffer status
]
