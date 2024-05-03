Class {
	#name : #ConcreteB,
	#superclass : #AbstractB,
	#instVars : [
		'b'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
ConcreteB class >> reStoreDefinition [

	^super reStoreDefinition
		define: #b as: String;
		yourself
]
