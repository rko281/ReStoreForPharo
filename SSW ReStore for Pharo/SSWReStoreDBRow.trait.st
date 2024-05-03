Trait {
	#name : 'SSWReStoreDBRow',
	#instVars : [
		'columns',
		'fieldMap'
	],
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'instance creation' }
SSWReStoreDBRow classSide >> newWithColumns: colsCollection data: dataCollection query: aDBQuery [

	^self new
		columns: colsCollection data: dataCollection query: aDBQuery;
		yourself
]

{ #category : 'accessing' }
SSWReStoreDBRow >> atIndex: anInteger [

	^self data at: anInteger
]

{ #category : 'accessing' }
SSWReStoreDBRow >> columns [

	^columns ifNil: [columns := self columnNames collect: [ :each | SSWDBCColAttr new name: each; yourself ]]
]

{ #category : 'initializing' }
SSWReStoreDBRow >> columns: colsCollection data: dataCollection query: aDBQuery [

	self 
		columns: colsCollection;
		data: dataCollection.
		
	aDBQuery isNil ifFalse: [ self createFieldMapFrom: aDBQuery ]
]

{ #category : 'initializing' }
SSWReStoreDBRow >> createFieldMapFrom: aDBQuery [

	fieldMap := Dictionary new.
	self columns with: self data do: 
		[ :column :value || field |
		field := aDBQuery fieldNamed: column fieldName.
		column field: field.
		fieldMap at: field put: value ]
]

{ #category : 'initializing' }
SSWReStoreDBRow >> deAliasQueryFieldsFor: aDBQueryTable [

	"The receiver is derived from a query containing the given SSWDBQueryTable as an alias for an actual SSWDBTable.
	To allow field lookup by the original SSWDBTable, initialize the field map based on the original, non-aliased, fields"

	| columns contents |
	
	columns := self columns.
	contents := self data.

	fieldMap := Dictionary new: columns size.
	1 to: columns size do: [ :index | (columns at: index) field ifNotNil: [ :field | field table == aDBQueryTable ifTrue: [fieldMap at: field field put: (contents at: index)]]]
]

{ #category : 'accessing' }
SSWReStoreDBRow >> fieldMap [
	^ fieldMap
]

{ #category : 'accessing' }
SSWReStoreDBRow >> fieldMap: anObject [
	fieldMap := anObject
]

{ #category : 'accessing' }
SSWReStoreDBRow >> lookupField: aField [

	^fieldMap at: aField ifAbsent: [ nil ]
]
