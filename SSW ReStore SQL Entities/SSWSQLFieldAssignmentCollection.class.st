"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLFieldAssignmentCollection,
	#superclass : #SSWSQLCollection,
	#type : #variable,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #actions }
SSWSQLFieldAssignmentCollection >> applyTo: anObject [

	self do: [ :fieldAssignment | fieldAssignment applyTo: anObject]
]

{ #category : #output }
SSWSQLFieldAssignmentCollection >> sqlConcatenator [

	"A comma is used to separate a list of field assignments 
	in an SQL UPDATE query"
	
	^', '
]
