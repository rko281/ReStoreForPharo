"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #GenericTest,
	#superclass : #Object,
	#instVars : [
		'name',
		'component'
	],
	#classInstVars : [
		'componentDefinition'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
GenericTest class >> componentDefinition: anObject [

	componentDefinition := anObject

	
]

{ #category : #public }
GenericTest class >> reStoreDefinition [

	^super reStoreDefinition 
		define: #name as: (String maxSize: 128);
		define: #component as: componentDefinition;
		yourself
]

{ #category : #accessing }
GenericTest >> component [
	^component
]

{ #category : #accessing }
GenericTest >> component: anObject [
	component := anObject
]

{ #category : #accessing }
GenericTest >> name [
	^name
]

{ #category : #accessing }
GenericTest >> name: anObject [
	name := anObject
]
