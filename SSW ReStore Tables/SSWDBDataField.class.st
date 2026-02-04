Class {
	#name : 'SSWDBDataField',
	#superclass : 'SSWDBStaticField',
	#instVars : [
		'isPolymorphic'
	],
	#category : 'SSW ReStore Tables'
}

{ #category : 'accessing' }
SSWDBDataField >> equivalentIn: anSSWDBTable [

	"For data fields ask the table to look for an equivalent"

	^(super equivalentIn: anSSWDBTable) ifNotNil: [ :field | anSSWDBTable equivalentDataFieldTo: field]
]

{ #category : 'initialize/release' }
SSWDBDataField >> initialize [

	super initialize.
	isPolymorphic := false
]

{ #category : 'accessing' }
SSWDBDataField >> isPolymorphic [
	"Answer whether the receiver is polymorphic, that is,
	another table in the hierarchy has a differently-defined field of the same name."

	^ isPolymorphic
]

{ #category : 'accessing' }
SSWDBDataField >> isPolymorphic: anObject [

	isPolymorphic := anObject
]

{ #category : 'actions' }
SSWDBDataField >> populateObject: anObject with: aValue [

	(self convertValue: aValue) ifNotNil: [ :obj | self accessor value: obj in: anObject]
]
