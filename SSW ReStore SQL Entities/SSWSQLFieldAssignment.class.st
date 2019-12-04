"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLFieldAssignment,
	#superclass : #SSWSQLFieldValueConjunction,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #actions }
SSWSQLFieldAssignment >> , anSSWSQLFieldAssignment [

	^SSWSQLFieldAssignmentCollection with: self with: anSSWSQLFieldAssignment
]

{ #category : #actions }
SSWSQLFieldAssignment >> applyTo: anObject [

	"The receiver relates a field (which relates to an instance var) to a value (Smalltalk object).
	'Apply' the receiver assignment to anObject by assigning its value to its field's inst var
	
	ASSERT: anObject class = self field table instanceClass"
	
	self field accessor value: self value in: anObject
]

{ #category : #output }
SSWSQLFieldAssignment >> writeConjunctionSQLOn: aStream [

	"The conjunction for assignment is simply '=' "
	
	aStream nextPut: $=
]

{ #category : #output }
SSWSQLFieldAssignment >> writeFieldSQLOn: aStream [

	"Ensure that the 'update' variant of the field is used"
	
	self field writeSQLForUpdateOn: aStream

]
