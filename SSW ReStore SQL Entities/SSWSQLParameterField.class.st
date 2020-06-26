"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLParameterField,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #'instance creation' }
SSWSQLParameterField class >> forValue: anObject [

	^self new
		value: anObject;
		yourself
]

{ #category : #testing }
SSWSQLParameterField >> canBeParameterized [

	^true
]

{ #category : #testing }
SSWSQLParameterField >> requiresAliasing [

	^true
]

{ #category : #accessing }
SSWSQLParameterField >> value [
	^value
]

{ #category : #accessing }
SSWSQLParameterField >> value: anObject [
	value := anObject
]

{ #category : #writing }
SSWSQLParameterField >> writeAliasedSQLOn: aStream [

	"For situations where duplicate field names are anticipated
	- write the SQL of the receiver on aStream, but use aliased names to force uniqueness"
	
	aStream nextPutAliasedField: self
]

{ #category : #writing }
SSWSQLParameterField >> writeSQLOn: aStream [

	^self value writeSQLOn: aStream forField: self
]
