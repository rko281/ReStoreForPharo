Class {
	#name : #SSWDBRenamedInstVar,
	#superclass : #SSWDBInstVarDefinition,
	#instVars : [
		'previousName'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #accessing }
SSWDBRenamedInstVar >> databaseFieldNameIn: anSSWDBTable [

	"Base the field name on the previousName"

	^anSSWDBTable dbNameFor: self previousName
]

{ #category : #accessing }
SSWDBRenamedInstVar >> previousName [
	^previousName
]

{ #category : #accessing }
SSWDBRenamedInstVar >> previousName: anObject [
	previousName := anObject
]
