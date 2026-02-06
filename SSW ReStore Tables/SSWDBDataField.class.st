Class {
	#name : 'SSWDBDataField',
	#superclass : 'SSWDBStaticField',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'converting' }
SSWDBDataField >> asPolymorphicDataField [

	| polymorphic |

	polymorphic := SSWDBPolymorphicDataField new.

	polymorphic
		name: self name;
		table: self table;
		accessor: self accessor;
		columnIndex: self columnIndex;
		targetClass: self targetClass.

	self isDependent ifTrue: [polymorphic beDependent].
	self isRelated ifTrue: [polymorphic beRelated].

	^polymorphic
]

{ #category : 'actions' }
SSWDBDataField >> populateObject: anObject with: aValue [

	(self convertValue: aValue) ifNotNil: [ :obj | self accessor value: obj in: anObject]
]
