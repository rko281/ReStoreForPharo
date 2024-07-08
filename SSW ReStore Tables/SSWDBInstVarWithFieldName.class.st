Class {
	#name : 'SSWDBInstVarWithFieldName',
	#superclass : 'SSWDBInstVarDefinition',
	#instVars : [
		'fieldName'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'accessing' }
SSWDBInstVarWithFieldName >> databaseFieldNameIn: anSSWDBTable [

	"Use the configured fieldName"

	^self fieldName
]

{ #category : 'accessing' }
SSWDBInstVarWithFieldName >> fieldName [
	^fieldName
]

{ #category : 'accessing' }
SSWDBInstVarWithFieldName >> fieldName: anObject [
	fieldName := anObject
]
