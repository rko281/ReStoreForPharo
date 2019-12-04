"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBStaticDictionarySpec,
	#superclass : #SSWDBKeyedStaticCollectionSpec,
	#instVars : [
		'keyClass',
		'isKeyDependent',
		'isKeyRelated'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #'actions - api' }
SSWDBStaticDictionarySpec >> aboutToBeUnstored: aProxyObject [

	"Also unstore member keys, if the receiver is so dependent"

	self isKeyDependent ifTrue: [(self accessor valueIn: aProxyObject) keysDo: [ :each | each unstore]].

	^super aboutToBeUnstored: aProxyObject
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> beKeyDependent [

	isKeyDependent := true
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> beKeyRelated [

	isKeyRelated := true
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> beKeyUnrelated [

	isKeyRelated := false
]

{ #category : #initializing }
SSWDBStaticDictionarySpec >> createCollectionTable [

	"Intercept to set the Class of the key field in the collection table"
		
	super createCollectionTable.

	(self collectionTable fieldAccessing: #index) targetClass: self keyClass
]

{ #category : #'initialize/release' }
SSWDBStaticDictionarySpec >> initialize [

	super initialize.

	isKeyDependent := false.
	isKeyRelated := false
]

{ #category : #testing }
SSWDBStaticDictionarySpec >> isKeyDependent [

	"Dictionary keys can optionally be dependent (see isValueDependent)"

	^isKeyDependent
]

{ #category : #testing }
SSWDBStaticDictionarySpec >> isKeyRelated [

	"Dictionary keys can optionally be related (see isValueRelated)"

	^isKeyRelated
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyClass [

	"keyClass stores the Class of the objects that are the keys to this Dictionary.
	This should be a valid base class (String, Date etc.) or a persistent class"

	^keyClass
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> keyClass: aBasicClass [

	"keyClass stores the Class of the objects that are the keys to this Dictionary.
	This should be a valid base class (String, Date etc.) or a persistent class"

	keyClass := aBasicClass
]

{ #category : #accessing }
SSWDBStaticDictionarySpec >> setKeyClass: aClass [

	"Double-despatch to the argument"
	
	aClass beKeyClassOf: self

]
