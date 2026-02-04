Class {
	#name : 'ConcreteReferenceA',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
ConcreteReferenceA class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: (String maxSize: 100);
		yourself
]

{ #category : 'accessing' }
ConcreteReferenceA >> name [

	^ name
]

{ #category : 'accessing' }
ConcreteReferenceA >> name: anObject [

	name := anObject
]
