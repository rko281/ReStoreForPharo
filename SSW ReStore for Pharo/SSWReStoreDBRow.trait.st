Trait {
	#name : #SSWReStoreDBRow,
	#instVars : [
		'fieldMap'
	],
	#category : #'SSW ReStore for Pharo'
}

{ #category : #'instance creation' }
SSWReStoreDBRow classSide >> newWithColumns: colsCollection data: dataCollection query: aDBQuery [

	^self new
		columns: colsCollection data: dataCollection query: aDBQuery;
		yourself
]

{ #category : #accessing }
SSWReStoreDBRow >> atField: aField [

	^self atField: aField ifAbsent: [nil]
]

{ #category : #accessing }
SSWReStoreDBRow >> atField: aField ifAbsent: aBlock [

	^fieldMap at: aField ifAbsent: aBlock
]

{ #category : #accessing }
SSWReStoreDBRow >> atIndex: anInteger [

	^self data at: anInteger
]

{ #category : #initializing }
SSWReStoreDBRow >> columns: colsCollection data: dataCollection query: aDBQuery [

	self 
		columns: colsCollection;
		data: dataCollection;
		createFieldMapFrom: aDBQuery
]

{ #category : #initializing }
SSWReStoreDBRow >> createFieldMapFrom: aDBQuery [

	fieldMap := Dictionary new.
	self columns with: self data do: 
		[ :column :value | 
		fieldMap at: (aDBQuery fieldNamed: column fieldName) put: value ]
]

{ #category : #accessing }
SSWReStoreDBRow >> fieldMap [
	^ fieldMap
]

{ #category : #accessing }
SSWReStoreDBRow >> fieldMap: anObject [
	fieldMap := anObject
]
