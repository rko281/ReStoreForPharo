Class {
	#name : 'SSWDBDataField',
	#superclass : 'SSWDBStaticField',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'accessing' }
SSWDBDataField >> equivalentIn: anSSWDBTable [

	"For data fields ask the table to look for an equivalent"

	^(super equivalentIn: anSSWDBTable) ifNotNil: [ :field | anSSWDBTable equivalentDataFieldTo: field]
]

{ #category : 'actions' }
SSWDBDataField >> populateObject: anObject with: aValue [

	(self convertValue: aValue) ifNotNil: [ :obj | self accessor value: obj in: anObject]
]
