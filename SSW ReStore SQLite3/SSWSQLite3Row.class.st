Class {
	#name : #SSWSQLite3Row,
	#superclass : #SQLite3Row,
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#category : #'SSW ReStore SQLite3'
}

{ #category : #accessing }
SSWSQLite3Row >> columns [

	^columnNames collect: [ :each | SSWDBCColAttr new name: each; yourself ]
]

{ #category : #accessing }
SSWSQLite3Row >> columns: aCollection [

	columnNames := aCollection
]

{ #category : #accessing }
SSWSQLite3Row >> data [

	^values
]

{ #category : #accessing }
SSWSQLite3Row >> data: aCollection [

	values := aCollection
]
