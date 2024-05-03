Class {
	#name : #AbstractA,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
AbstractA class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: String;
		yourself
]

{ #category : #public }
AbstractA class >> shouldSubclassesInheritPersistencyFalse [

	^self ~~ AbstractA
]
