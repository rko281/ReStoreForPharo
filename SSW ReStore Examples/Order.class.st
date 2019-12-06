Class {
	#name : #Order,
	#superclass : #Object,
	#instVars : [
		'date',
		'product',
		'quantity',
		'customer'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #persistence }
Order class >> reStoreDefinition [

	^super reStoreDefinition
		define: #date as: Date;
		define: #product as: Product;
		define: #quantity as: Integer;
		define: #customer as: Customer;
		yourself.
]

{ #category : #accessing }
Order >> customer [
	^ customer
]

{ #category : #accessing }
Order >> customer: anObject [
	customer := anObject
]

{ #category : #accessing }
Order >> date [
	^ date
]

{ #category : #accessing }
Order >> date: anObject [
	date := anObject
]

{ #category : #printing }
Order >> displayOn: aStream [

	aStream nextPutAll: self product name; space; nextPutAll: ' x'; print: self quantity
]

{ #category : #printing }
Order >> printOn: aStream [
	
	super printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $).
]

{ #category : #accessing }
Order >> product [
	^ product
]

{ #category : #accessing }
Order >> product: anObject [
	product := anObject
]

{ #category : #accessing }
Order >> quantity [
	^ quantity
]

{ #category : #accessing }
Order >> quantity: anObject [
	quantity := anObject
]
