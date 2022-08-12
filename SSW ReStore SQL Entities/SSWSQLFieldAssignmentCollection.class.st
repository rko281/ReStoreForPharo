"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
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

{ #category : #actions }
SSWSQLFieldAssignmentCollection >> copyTo: anObject [

	self do: [ :fieldAssignment | fieldAssignment copyTo: anObject]
]

{ #category : #output }
SSWSQLFieldAssignmentCollection >> sqlConcatenator [

	"A comma is used to separate a list of field assignments 
	in an SQL UPDATE query"
	
	^', '
]
