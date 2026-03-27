Class {
	#name : 'SomeObjectA',
	#superclass : 'SomeObject',
	#instVars : [
		'varA'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SomeObjectA class >> reStoreDefinition [

	^super reStoreDefinition
		define: #varA as: TestBitmask;
		yourself
]

{ #category : 'accessing' }
SomeObjectA >> varA [

	^ varA
]

{ #category : 'accessing' }
SomeObjectA >> varA: anObject [

	varA := anObject
]
