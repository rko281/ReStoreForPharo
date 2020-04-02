"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBDeletedObject,
	#superclass : #DeafObject,
	#instVars : [
		'deletedObjectClass',
		'id'
	],
	#category : #'SSW ReStore Base Additions'
}

{ #category : #'instance creation' }
SSWDBDeletedObject class >> newForClass: aClass id: anInteger [

	^self basicNew
		deletedObjectClass: aClass;
		id: anInteger;
		yourself
]

{ #category : #accessing }
SSWDBDeletedObject >> _id [

	^self id
]

{ #category : #accessing }
SSWDBDeletedObject >> deletedObjectClass [

	"deletedObjectClass stores the Class of object for which the receiver 
	represents a deleted instance"

	^deletedObjectClass
]

{ #category : #accessing }
SSWDBDeletedObject >> deletedObjectClass: aClass [

	"deletedObjectClass stores the Class of object for which the receiver 
	represents a deleted instance"

	deletedObjectClass := aClass
]

{ #category : #printing }
SSWDBDeletedObject >> displayOn: aStream [

	self id displayOn: aStream
]

{ #category : #accessing }
SSWDBDeletedObject >> id [

	"id stores the unique ID of the instance of deletedObjectClass
	that the receiver represents"

	^id
]

{ #category : #accessing }
SSWDBDeletedObject >> id: anInteger [

	"id stores the unique ID of the instance of deletedObjectClass
	that the receiver represents"

	id := anInteger
]

{ #category : #testing }
SSWDBDeletedObject >> isDBDeleted [

	^true
]

{ #category : #printing }
SSWDBDeletedObject >> printOn: aStream [

	aStream 
		nextPutAll: 'A deleted ';
		nextPutAll: self deletedObjectClass name;
		nextPutAll: '; ID: ';
		nextPutAll: self id printString
]

{ #category : #copying }
SSWDBDeletedObject >> shallowCopy [

	"Do not copy the receiver"

	^self

]

{ #category : #testing }
SSWDBDeletedObject >> unstore [

	"Do nothing - the receiver is already deleted"

	^self
]
