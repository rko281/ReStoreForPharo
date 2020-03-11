"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SimpleProductOrder,
	#superclass : #Object,
	#instVars : [
		'customer',
		'product',
		'quantity',
		'date'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SimpleProductOrder class >> reStoreDefinition [

	^super reStoreDefinition
		define: #customer as: SimplePerson;
		define: #product as: SimpleProduct;
		define: #date as: Date;
		define: #quantity as: Integer;
		yourself
]

{ #category : #comparing }
SimpleProductOrder >> <= anOrder [

	^self quantity <= anOrder quantity
]

{ #category : #accessing }
SimpleProductOrder >> customer [
	^customer
]

{ #category : #accessing }
SimpleProductOrder >> customer: anObject [
	customer := anObject
]

{ #category : #accessing }
SimpleProductOrder >> date [
	^date
]

{ #category : #accessing }
SimpleProductOrder >> date: anObject [
	date := anObject
]

{ #category : #accessing }
SimpleProductOrder >> product [
	^product
]

{ #category : #accessing }
SimpleProductOrder >> product: anObject [
	product := anObject
]

{ #category : #accessing }
SimpleProductOrder >> quantity [
	^quantity
]

{ #category : #accessing }
SimpleProductOrder >> quantity: anObject [
	quantity := anObject
]
