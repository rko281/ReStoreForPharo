Class {
	#name : 'SomeObject',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SomeObject class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: String;
		yourself
]

{ #category : 'accessing' }
SomeObject >> name [

	^ name
]

{ #category : 'accessing' }
SomeObject >> name: anObject [

	name := anObject
]
