Trait {
	#name : 'SSWReStoreDBRow',
	#instVars : [
		'columns'
	],
	#classTraits : '{} + TraitedClass',
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'accessing' }
SSWReStoreDBRow >> atIndex: anInteger [

	^self data at: anInteger
]

{ #category : 'accessing' }
SSWReStoreDBRow >> columns [

	^columns
]

{ #category : 'accessing' }
SSWReStoreDBRow >> columns: aCollection [

	columns := aCollection
]

{ #category : 'initializing' }
SSWReStoreDBRow >> deAliasQueryFieldsFor: aDBQueryTable [

	"The receiver is derived from a query containing the given SSWDBQueryTable as an alias for an actual SSWDBTable.
	To allow field lookup by the original SSWDBTable, initialize the field map based on the original, non-aliased, fields"

	columns := 
		columns collect: 
			[ :each |
			each field 
				ifNil: [each] 
				ifNotNil: [ :field | field table == aDBQueryTable ifTrue: [each copy field: field field] ifFalse: [each copy field: nil]]]
]

{ #category : 'accessing' }
SSWReStoreDBRow >> lookupField: aField [

	"Optimised method: 
		Use the columnIndex where available;
		In the common case fields will be identical; check for this first. 
		Use to:do: to maximize inlining and avoid full blocks. "

	aField columnIndex ifNotNil: 
		[ :index |
		(columns at: index ifAbsent: [nil]) ifNotNil: 
			[ :column |
			(column field == aField or: [column field = aField]) ifTrue: [^self data at: index]]].

	1 to: columns size do: [ :index | (columns at: index) field == aField ifTrue: [^self data at: index]].
	1 to: columns size do: [ :index | (columns at: index) field = aField ifTrue: [^self data at: index]].

	^nil
]

{ #category : 'accessing' }
SSWReStoreDBRow >> lookupIDField: aField [

	"Optimised lookup for ID fields which are usually first"

	^(columns at: 1) field == aField 
		ifTrue: [self data  at: 1]
		ifFalse: [self lookupField: aField]
]

{ #category : 'accessing' }
SSWReStoreDBRow >> populateObject: anObject from: anSSWDBTable [

	1 to: columns size do: 
		[ :index | 
		(columns at: index) field ifNotNil: 
			[ :field |  
			(field table == anSSWDBTable or: [field table = anSSWDBTable]) ifTrue: 
				[field populateObject: anObject with: (self data at: index)]]]
]
