Class {
	#name : 'AbstractB',
	#superclass : 'AbstractA',
	#instVars : [
		'reference'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
AbstractB class >> addClassDefinitionToEmpty: aClassDef [

	super addClassDefinitionTo: aClassDef
]

{ #category : 'public' }
AbstractB class >> reStoreDefinitionEmpty [

	^super reStoreDefinition
]

{ #category : 'public' }
AbstractB class >> shouldSubclassesInheritPersistencyFalse [

	^self ~~ AbstractB
]

{ #category : 'accessing' }
AbstractB >> reference [

	^ reference
]

{ #category : 'accessing' }
AbstractB >> reference: anObject [

	reference := anObject
]
