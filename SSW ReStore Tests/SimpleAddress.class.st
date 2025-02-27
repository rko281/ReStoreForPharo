"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SimpleAddress',
	#superclass : 'Object',
	#instVars : [
		'line1',
		'postcode'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SimpleAddress class >> reStoreDefinition [

	^super reStoreDefinition
		define: #line1 as: (String maxSize: 128);
		define: #postcode as: (String maxSize: 32);
		yourself
]

{ #category : 'accessing' }
SimpleAddress >> line1 [
	^line1
]

{ #category : 'accessing' }
SimpleAddress >> line1: anObject [
	line1 := anObject
]

{ #category : 'accessing' }
SimpleAddress >> postcode [
	^postcode
]

{ #category : 'accessing' }
SimpleAddress >> postcode: anObject [
	postcode := anObject
]
