"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBClassWithInfo,
	#superclass : #Object,
	#category : #'SSW ReStore Base Additions'
}

{ #category : #defining }
SSWDBClassWithInfo >> beKeyClassOf: aCollectionSpec [

	"Polymorphic with Class implementation"

	aCollectionSpec keyClass: self
]

{ #category : #defining }
SSWDBClassWithInfo >> beTargetClassOf: aCollectionSpec [

	"Polymorphic with Class implementation"

	aCollectionSpec targetClass: self
]

{ #category : #testing }
SSWDBClassWithInfo >> includesBehavior: aBehavior [

	"Required class-like behavior"

	^self infoClass includesBehavior: aBehavior
]

{ #category : #constants }
SSWDBClassWithInfo >> infoClass [

	"Return the class which the receiver represents a paramterised version of.
	Subclasses should override"

	^self subclassResponsibility
]

{ #category : #testing }
SSWDBClassWithInfo >> isPersistentBaseClass [

	^self infoClass isPersistentBaseClass

]

{ #category : #'instance creation' }
SSWDBClassWithInfo >> new [

	"Create and return an instance of the receiver's infoClass"

	^self infoClass new
]
