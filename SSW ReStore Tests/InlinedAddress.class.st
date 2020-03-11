Class {
	#name : #InlinedAddress,
	#superclass : #Object,
	#instVars : [
		'line1',
		'postcode'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
InlinedAddress class >> reStoreDefinition [

	^super reStoreDefinition
		define: #line1 as: (String maxSize: 128);
		define: #postcode as: InlinedPostcode inlined
]

{ #category : #comparing }
InlinedAddress >> = anotherAddress [

	^(self line1 = anotherAddress line1) & (self postcode = anotherAddress postcode)
]

{ #category : #accessing }
InlinedAddress >> hash [

	^self line1 hash
]

{ #category : #accessing }
InlinedAddress >> line1 [
	^line1
]

{ #category : #accessing }
InlinedAddress >> line1: anObject [
	line1 := anObject
]

{ #category : #accessing }
InlinedAddress >> postcode [
	^postcode
]

{ #category : #accessing }
InlinedAddress >> postcode: anObject [
	postcode := anObject
]
