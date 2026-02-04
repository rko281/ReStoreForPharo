Class {
	#name : 'ConcreteReferenceB',
	#superclass : 'Object',
	#instVars : [
		'number'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
ConcreteReferenceB class >> reStoreDefinition [

	^super reStoreDefinition
		define: #number as: Integer;
		yourself
]

{ #category : 'accessing' }
ConcreteReferenceB >> number [

	^ number
]

{ #category : 'accessing' }
ConcreteReferenceB >> number: anObject [

	number := anObject
]
