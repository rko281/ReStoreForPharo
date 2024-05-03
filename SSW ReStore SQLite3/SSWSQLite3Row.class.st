Class {
	#name : 'SSWSQLite3Row',
	#superclass : 'SQLite3Row',
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#category : 'SSW ReStore SQLite3',
	#package : 'SSW ReStore SQLite3'
}

{ #category : 'accessing' }
SSWSQLite3Row >> columns: aCollection [

	columns := aCollection
]

{ #category : 'accessing' }
SSWSQLite3Row >> contents [

	^self
]

{ #category : 'accessing' }
SSWSQLite3Row >> data [

	^values
]

{ #category : 'accessing' }
SSWSQLite3Row >> data: aCollection [

	values := aCollection
]

{ #category : 'accessing' }
SSWSQLite3Row >> values [

	^values
]
