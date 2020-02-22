Class {
	#name : #Customer,
	#superclass : #Object,
	#instVars : [
		'firstName',
		'surname',
		'emailAddress',
		'dateOfBirth',
		'address',
		'orders'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #persistence }
Customer class >> reStoreDefinition [

	^super reStoreDefinition
		define: #surname as: (String maxSize: 100);
		define: #firstName as: (String maxSize: 100);
		define: #emailAddress as: (String maxSize: 100);
		define: #dateOfBirth as: Date;
		define: #address as: Address dependent;
		define: #orders as: (OrderedCollection of: CustomerOrder dependent owner: #customer);
		yourself.
]

{ #category : #adding }
Customer >> addOrder: anOrder [

	self orders addLast: anOrder
]

{ #category : #accessing }
Customer >> address [
	^ address
]

{ #category : #accessing }
Customer >> address: anObject [
	address := anObject
]

{ #category : #accessing }
Customer >> dateOfBirth [
	^ dateOfBirth
]

{ #category : #accessing }
Customer >> dateOfBirth: anObject [
	dateOfBirth := anObject
]

{ #category : #printing }
Customer >> displayOn: aStream [

	aStream nextPutAll: self fullName
]

{ #category : #accessing }
Customer >> emailAddress [
	^ emailAddress
]

{ #category : #accessing }
Customer >> emailAddress: anObject [
	emailAddress := anObject
]

{ #category : #accessing }
Customer >> firstName [
	^ firstName
]

{ #category : #accessing }
Customer >> firstName: anObject [
	firstName := anObject
]

{ #category : #accessing }
Customer >> fullName [

	^self firstName, ' ', self surname
]

{ #category : #initialization }
Customer >> initialize [

	self orders: OrderedCollection new
]

{ #category : #accessing }
Customer >> orders [
	^ orders
]

{ #category : #accessing }
Customer >> orders: anObject [
	orders := anObject
]

{ #category : #printing }
Customer >> printOn: aStream [
	
	super printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $).
]

{ #category : #accessing }
Customer >> surname [
	^ surname
]

{ #category : #accessing }
Customer >> surname: anObject [
	surname := anObject
]
