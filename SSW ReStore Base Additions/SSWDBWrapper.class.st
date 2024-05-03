"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBWrapper,
	#superclass : #Object,
	#instVars : [
		'object'
	],
	#category : #'SSW ReStore Base Additions'
}

{ #category : #'instance creation' }
SSWDBWrapper class >> on: anObject [

	^self new
		object: anObject;
		yourself

]

{ #category : #accessing }
SSWDBWrapper >> object [

	"object stores the Object being wrapped"

	^object
]

{ #category : #accessing }
SSWDBWrapper >> object: anObject [

	"object stores the Object being wrapped"

	object := anObject
]
