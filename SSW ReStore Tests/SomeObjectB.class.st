Class {
	#name : 'SomeObjectB',
	#superclass : 'SomeObject',
	#instVars : [
		'varB'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SomeObjectB class >> reStoreDefinition [

	^super reStoreDefinition
		define: #varB as: String;
		yourself
]

{ #category : 'accessing' }
SomeObjectB >> varB [

	^ varB
]

{ #category : 'accessing' }
SomeObjectB >> varB: anObject [

	varB := anObject
]
