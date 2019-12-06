Class {
	#name : #Product,
	#superclass : #Object,
	#instVars : [
		'name',
		'description'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #persistence }
Product class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: (String maxSize: 100);
		define: #description as: String;
		yourself.
]

{ #category : #accessing }
Product >> description [
	^ description
]

{ #category : #accessing }
Product >> description: anObject [
	description := anObject
]

{ #category : #printing }
Product >> displayOn: aStream [

	aStream nextPutAll: self name
]

{ #category : #accessing }
Product >> name [
	^ name
]

{ #category : #accessing }
Product >> name: anObject [
	name := anObject
]

{ #category : #printing }
Product >> printOn: aStream [
	
	super printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $).
]
