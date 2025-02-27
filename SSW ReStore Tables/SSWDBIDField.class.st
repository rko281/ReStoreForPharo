Class {
	#name : 'SSWDBIDField',
	#superclass : 'SSWDBStaticField',
	#instVars : [
		'dataField'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'initialize/release' }
SSWDBIDField >> accessInstVarNamed: aSymbol [

	"Configure the receiver to access the target class's inst var named aSymbol, in addition to the proxy's id value"

	self dataField: 
		(SSWDBDataField new
			name: self name;
			table: self table;
			targetClass: self targetClass;
			accessor: ((self targetClass reStoreInstVarAccessorIn: self sqlDialect) access: aSymbol in: self table instanceClass);
			yourself)
]

{ #category : 'testing' }
SSWDBIDField >> accesses: aSymbol [

	"Additionally check the dataField"

	^(super accesses: aSymbol) or: [dataField notNil and: [dataField accesses: aSymbol]]
]

{ #category : 'accessing' }
SSWDBIDField >> dataField [

	"dataField optionally stores an SSWDBDataField that relates to an instance variable holding the ID value in an actual persistent object (in addition to its proxy).
	By default this is nil - persistent objects do not normally store their ID"

	^dataField
]

{ #category : 'accessing' }
SSWDBIDField >> dataField: anSSWDBDataField [

	"dataField optionally stores an SSWDBDataField that relates to an instance variable holding the ID value in an actual persistent object (in addition to its proxy).
	By default this is nil - persistent objects do not normally store their ID"

	dataField := anSSWDBDataField
]

{ #category : 'initialize/release' }
SSWDBIDField >> initialize [

	super initialize.

	self accessor: SSWDBIDAccessor new
]

{ #category : 'accessing' }
SSWDBIDField >> lookupIn: aDBRow [

	^aDBRow lookupIDField: self
]

{ #category : 'actions' }
SSWDBIDField >> populateObject: anObject with: aValue [

	dataField ifNotNil: [ :df | df populateObject: anObject with: aValue]
]
