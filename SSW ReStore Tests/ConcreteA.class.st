Class {
	#name : #ConcreteA,
	#superclass : #AbstractB,
	#instVars : [
		'a'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
ConcreteA class >> reStoreDefinition [

	^super reStoreDefinition
		define: #a as: String;
		yourself
]
