Class {
	#name : #CustomerOrderItem,
	#superclass : #Object,
	#instVars : [
		'order',
		'product',
		'quantity'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #public }
CustomerOrderItem class >> reStoreDefinition [

	^super reStoreDefinition
		define: #order as: CustomerOrder;
		define: #product as: Product;
		define: #quantity as: Integer;
		yourself.
]

{ #category : #printing }
CustomerOrderItem >> displayOn: aStream [

	aStream nextPutAll: self product name; space; nextPutAll: ' x'; print: self quantity
]

{ #category : #accessing }
CustomerOrderItem >> order [
	^ order
]

{ #category : #accessing }
CustomerOrderItem >> order: anObject [
	order := anObject
]

{ #category : #printing }
CustomerOrderItem >> printOn: aStream [
	
	super printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $).
]

{ #category : #accessing }
CustomerOrderItem >> product [
	^ product
]

{ #category : #accessing }
CustomerOrderItem >> product: anObject [
	product := anObject
]

{ #category : #accessing }
CustomerOrderItem >> quantity [
	^ quantity
]

{ #category : #accessing }
CustomerOrderItem >> quantity: anObject [
	quantity := anObject
]

{ #category : #accessing }
CustomerOrderItem >> totalPrice [

	^self quantity * self product price
]
