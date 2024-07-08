"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SimpleProduct',
	#superclass : 'Object',
	#instVars : [
		'description',
		'supplierPrice',
		'retailPrice'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SimpleProduct class >> reStoreDefinition [

	^super reStoreDefinition
		define: #description as: (String maxSize: 100);
		define: #supplierPrice as: (ScaledDecimal withScale: 2);
		define: #retailPrice as: (ScaledDecimal withScale: 2);
		yourself
]

{ #category : 'accessing' }
SimpleProduct >> description [
	^description
]

{ #category : 'accessing' }
SimpleProduct >> description: anObject [
	description := anObject
]

{ #category : 'calculating' }
SimpleProduct >> markUp [

	^self retailPrice - self supplierPrice
]

{ #category : 'calculating' }
SimpleProduct >> profitMargin [

	^((self markUp * 100) / self supplierPrice) rounded
]

{ #category : 'accessing' }
SimpleProduct >> retailPrice [
	^retailPrice
]

{ #category : 'accessing' }
SimpleProduct >> retailPrice: anObject [
	retailPrice := anObject
]

{ #category : 'accessing' }
SimpleProduct >> supplierPrice [
	^supplierPrice
]

{ #category : 'accessing' }
SimpleProduct >> supplierPrice: anObject [
	supplierPrice := anObject
]
