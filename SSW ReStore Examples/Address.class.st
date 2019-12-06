Class {
	#name : #Address,
	#superclass : #Object,
	#instVars : [
		'line1',
		'postcode',
		'country'
	],
	#category : #'SSW ReStore Examples'
}

{ #category : #persistence }
Address class >> reStoreDefinition [

	^super reStoreDefinition
		define: #line1 as: (String maxSize: 100);
		define: #postcode as: (String maxSize: 16);
		define: #country as: (String maxSize: 100);
		yourself.
]

{ #category : #accessing }
Address >> country [
	^ country
]

{ #category : #accessing }
Address >> country: anObject [
	country := anObject
]

{ #category : #accessing }
Address >> line1 [
	^ line1
]

{ #category : #accessing }
Address >> line1: anObject [
	line1 := anObject
]

{ #category : #accessing }
Address >> postcode [
	^ postcode
]

{ #category : #accessing }
Address >> postcode: anObject [
	postcode := anObject
]
