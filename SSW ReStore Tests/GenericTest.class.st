"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
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

{ #category : #comparing }
GenericTest >> = a [

	^self name = a name
]

{ #category : #adding }
GenericTest >> addToMultiKeyDictionary: aTest [

	^(self component at: aTest key ifAbsentPut: [OrderedCollection new]) add: aTest
]

{ #category : #adding }
GenericTest >> addToSingleKeyDictionary: aTest [

	^self component at: aTest key put: aTest
]

{ #category : #accessing }
GenericTest >> component [
	^component
]

{ #category : #accessing }
GenericTest >> component: anObject [
	component := anObject
]

{ #category : #comparing }
GenericTest >> hash [

	^self name hash
]

{ #category : #accessing }
GenericTest >> name [
	^name
]

{ #category : #accessing }
GenericTest >> name: anObject [
	name := anObject
]
