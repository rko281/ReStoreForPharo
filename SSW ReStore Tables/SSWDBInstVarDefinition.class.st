Class {
	#name : 'SSWDBInstVarDefinition',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'instance creation' }
SSWDBInstVarDefinition class >> name: aSymbol [

	^self new
		name: aSymbol;
		yourself
]

{ #category : 'converting' }
SSWDBInstVarDefinition >> asInstVarName [

	^self name
]

{ #category : 'accessing' }
SSWDBInstVarDefinition >> databaseFieldNameIn: anSSWDBTable [

	"Return the corresponding field name of this inst var in anSSWDBTable"

	^anSSWDBTable dbNameFor: self name
]

{ #category : 'accessing' }
SSWDBInstVarDefinition >> name [
	^name
]

{ #category : 'accessing' }
SSWDBInstVarDefinition >> name: anObject [
	name := anObject
]
