Class {
	#name : #AbstractB,
	#superclass : #AbstractA,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
AbstractB class >> addClassDefinitionToEmpty: aClassDef [

	super addClassDefinitionTo: aClassDef
]

{ #category : #public }
AbstractB class >> reStoreDefinitionEmpty [

	^super reStoreDefinition
]

{ #category : #public }
AbstractB class >> shouldSubclassesInheritPersistencyFalse [

	^self ~~ AbstractB
]
