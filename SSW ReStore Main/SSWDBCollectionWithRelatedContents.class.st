"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionWithRelatedContents,
	#superclass : #SSWDBObjectWithRelatedComponents,
	#instVars : [
		'cachedProxy'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #acccessing }
SSWDBCollectionWithRelatedContents >> collection [

	^self proxy 
		ifNil: [self object] 
		ifNotNil: [ :proxy | proxy _proxiedObject]
]

{ #category : #enumerating }
SSWDBCollectionWithRelatedContents >> componentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet [

	self isRelated ifFalse: [^self].

	self collection do:
		[ :each | 
		each withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]
]

{ #category : #testing }
SSWDBCollectionWithRelatedContents >> isRelated [

	^(self originatingComponent ifNil: [self proxy ifNotNil: [ :proxy | proxy _collectionSpec]])
		ifNil: [true]
		ifNotNil: [ :spec | spec isRelated]
]

{ #category : #acccessing }
SSWDBCollectionWithRelatedContents >> object: anObject [

	anObject isDBProxy 
		ifTrue: [cachedProxy := anObject _proxiedObject]
		ifFalse: [cachedProxy := anObject].

	super object: anObject
]

{ #category : #acccessing }
SSWDBCollectionWithRelatedContents >> proxy [

	self object isDBProxy ifTrue: [^self object].

	^cachedProxy isDBProxy 
		ifTrue: [cachedProxy]
		ifFalse: [self object _dbProxyIfNone: [nil]]
]
