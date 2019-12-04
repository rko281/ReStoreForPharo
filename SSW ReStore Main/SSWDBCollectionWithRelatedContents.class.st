"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionWithRelatedContents,
	#superclass : #SSWDBObjectWithRelatedComponents,
	#category : #'SSW ReStore Main'
}

{ #category : #enumerating }
SSWDBCollectionWithRelatedContents >> componentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet [

	| proxy |

	proxy := self object _dbProxyIn: aReStore ifNone: [nil]. 
	(proxy isNil or: [proxy _collectionSpec isRelated]) ifFalse: [^self].

	(proxy ifNil: [self object] ifNotNil: [ :prx | prx _proxiedObject]) do:
		[ :each | 
		each withRelatedComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]
]
