Class {
	#name : #Product,
	#superclass : #Object,
	#instVars : [
		'name',
		'description',
		'price'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #persistence }
Product class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: (String maxSize: 100);
		define: #description as: String;
		define: #price as: (ScaledDecimal withPrecision: 8 scale: 2);
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

{ #category : #accessing }
Product >> price [
	^ price
]

{ #category : #accessing }
Product >> price: anObject [
	price := anObject
]

{ #category : #printing }
Product >> printOn: aStream [
	
	super printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $).
]
