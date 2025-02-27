Class {
	#name : 'SSWDBDataField',
	#superclass : 'SSWDBStaticField',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'actions' }
SSWDBDataField >> populateObject: anObject with: aValue [

	(self convertValue: aValue) ifNotNil: [ :obj | self accessor value: obj in: anObject]
]
