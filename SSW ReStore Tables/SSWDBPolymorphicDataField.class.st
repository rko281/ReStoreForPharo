Class {
	#name : 'SSWDBPolymorphicDataField',
	#superclass : 'SSWDBDataField',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'actions' }
SSWDBPolymorphicDataField >> populateObject: anObject with: aValue from: anSSWDBTable [

	"For polymorphic fields ask anSSWDBTable for its concrete equivalent to the receiver to carry this out"

	^(anSSWDBTable equivalentDataFieldTo: self) ifNotNil: [ :concreteField | concreteField populateObject: anObject with: aValue from: anSSWDBTable]
]
