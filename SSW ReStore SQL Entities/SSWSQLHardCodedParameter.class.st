Class {
	#name : 'SSWSQLHardCodedParameter',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLHardCodedParameter class >> value: anObject [

	^self new 
		value: anObject;
		yourself
]

{ #category : 'testing' }
SSWSQLHardCodedParameter >> isSQLNull [

	^self value isNil
]

{ #category : 'testing' }
SSWSQLHardCodedParameter >> sqlCanBeParameterized [

	"I am hard-coded"
	^false
]

{ #category : 'accessing' }
SSWSQLHardCodedParameter >> value [

	^ value
]

{ #category : 'accessing' }
SSWSQLHardCodedParameter >> value: anObject [

	value := anObject
]

{ #category : 'printing' }
SSWSQLHardCodedParameter >> writeSQLOn: aStream [

	self value writeHardCodedSQLOn: aStream
]
