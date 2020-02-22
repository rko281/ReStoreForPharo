Class {
	#name : #CustomerOrder,
	#superclass : #Object,
	#instVars : [
		'orderDate',
		'customer',
		'items',
		'totalPrice'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #'instance creation' }
CustomerOrder class >> new [

	^super new
		items: OrderedCollection new;
		totalPrice: 0s2;
		yourself
]

{ #category : #persistence }
CustomerOrder class >> reStoreDefinition [

	^super reStoreDefinition
		define: #orderDate as: Date;
		define: #customer as: Customer;
		define: #items as: (OrderedCollection of: CustomerOrderItem dependent owner: #order);
		define: #totalPrice as: (ScaledDecimal withPrecision: 8 scale: 2);
		yourself.
]

{ #category : #adding }
CustomerOrder >> addItem: aCustomerOrderItem [

	self items add: aCustomerOrderItem.
	self totalPrice: (self totalPrice + aCustomerOrderItem totalPrice).
	^aCustomerOrderItem
]

{ #category : #accessing }
CustomerOrder >> customer [
	^ customer
]

{ #category : #accessing }
CustomerOrder >> customer: anObject [
	customer := anObject
]

{ #category : #accessing }
CustomerOrder >> items [
	^ items
]

{ #category : #accessing }
CustomerOrder >> items: anObject [
	items := anObject
]

{ #category : #accessing }
CustomerOrder >> orderDate [
	^ orderDate
]

{ #category : #accessing }
CustomerOrder >> orderDate: anObject [
	orderDate := anObject
]

{ #category : #accessing }
CustomerOrder >> totalPrice [
	^ totalPrice
]

{ #category : #accessing }
CustomerOrder >> totalPrice: anObject [
	totalPrice := anObject
]
