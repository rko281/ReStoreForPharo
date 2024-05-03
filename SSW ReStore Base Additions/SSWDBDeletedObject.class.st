"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
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

{ #category : #comparing }
SSWDBDeletedObject >> = anObject [ 

	^self class == anObject class and: [self deletedObjectClass = anObject deletedObjectClass and: [self id = anObject id]]
]

{ #category : #accessing }
SSWDBDeletedObject >> _id [

	^self id
]

{ #category : #accessing }
SSWDBDeletedObject >> _instVarAt: anInteger [

	"Encountered when 'recovering' a deleted object; ignore"

	^nil
]

{ #category : #accessing }
SSWDBDeletedObject >> _instVarAt: anInteger put: anObject [

	"Encountered when 'recovering' a deleted object; ignore"
]

{ #category : #copying }
SSWDBDeletedObject >> copy [

	"Do not copy the receiver"

	^self
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

{ #category : #comparing }
SSWDBDeletedObject >> hash [

	^deletedObjectClass hash bitXor: id hash
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

{ #category : #testing }
SSWDBDeletedObject >> unstore [

	"Do nothing - the receiver is already deleted"

	^self
]
