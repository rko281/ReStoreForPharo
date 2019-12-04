"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBObjectWithRelatedComponents,
	#superclass : #SSWDBObjectWithComponents,
	#category : #'SSW ReStore Main'
}

{ #category : #enumerating }
SSWDBObjectWithRelatedComponents >> componentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet [

	(aReStore tableForClass: self object class ifAbsent: [nil]) ifNotNil: 
		[ :table |
		table componentsDo: 
			[ :component |
			component relatedComponentsOf: self object do: 
				[ :each | 
				each withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]]]
]

{ #category : #accessing }
SSWDBObjectWithRelatedComponents >> withRelatedComponents [

	^self
]
