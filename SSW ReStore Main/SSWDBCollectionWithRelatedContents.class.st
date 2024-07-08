"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBCollectionWithRelatedContents',
	#superclass : 'SSWDBObjectWithRelatedComponents',
	#instVars : [
		'cachedProxy'
	],
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'accessing' }
SSWDBCollectionWithRelatedContents >> collection [

	^self proxy 
		ifNil: [self object] 
		ifNotNil: [ :proxy | proxy _proxiedObject]
]

{ #category : 'accessing' }
SSWDBCollectionWithRelatedContents >> collectionSpec [

	^self originatingComponent ifNil: [self proxy ifNotNil: [ :proxy | proxy _collectionSpec]]
]

{ #category : 'enumerating' }
SSWDBCollectionWithRelatedContents >> componentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet [

	| spec |

	spec := self collectionSpec.
	(spec isNil or: [spec isKeyRelated or: [spec isValueRelated]]) ifFalse: [^self].

	(spec isNil or: [spec isValueRelated])
	ifTrue: 
		[(spec isNil or: [spec isKeyRelated])
		ifTrue: 
			[self collection keysAndValuesDo:
				[ :key :value | 
				key withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet.
				value withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]]
		ifFalse: 
			[self collection do: [ :each | each withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]]]
	ifFalse: 
		[self collection keysDo: [ :key | key withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]]
]

{ #category : 'testing' }
SSWDBCollectionWithRelatedContents >> isRelated [

	^(self originatingComponent ifNil: [self proxy ifNotNil: [ :proxy | proxy _collectionSpec]])
		ifNil: [true]
		ifNotNil: [ :spec | spec isRelated]
]

{ #category : 'accessing' }
SSWDBCollectionWithRelatedContents >> object: anObject [

	anObject isDBProxy 
		ifTrue: [cachedProxy := anObject _proxiedObject]
		ifFalse: [cachedProxy := anObject].

	super object: anObject
]

{ #category : 'accessing' }
SSWDBCollectionWithRelatedContents >> proxy [

	self object isDBProxy ifTrue: [^self object].

	^cachedProxy isDBProxy 
		ifTrue: [cachedProxy]
		ifFalse: [self object _dbProxyIfNone: [nil]]
]
