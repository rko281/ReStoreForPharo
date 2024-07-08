"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBOwnedMultiValueCacheDictionarySpec',
	#superclass : 'SSWDBOwnedCacheDictionarySpec',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'testing' }
SSWDBOwnedMultiValueCacheDictionarySpec >> allElementsIn: aDictionary [

	^aDictionary inject: OrderedCollection new into: [ :all :each | all addAll: each; yourself]
]

{ #category : 'actions' }
SSWDBOwnedMultiValueCacheDictionarySpec >> copyCollection: aCollection [

	| copy |

	copy := aCollection copyEmpty.

	aCollection keysAndValuesDo: [ :key :values | copy at: key put: values copy].

	^copy
]

{ #category : 'testing' }
SSWDBOwnedMultiValueCacheDictionarySpec >> elementsIn: updatedCollection notIn: originalCollection [

	| additions |

	additions := OrderedCollection new.

	updatedCollection keysAndValuesDo: 
		[ :key :values || originalValues |
		originalValues := originalCollection at: key ifAbsent: [#()].
		values do: [ :each | (originalValues includes: each) ifFalse: [additions add: each]]].

	^additions
]

{ #category : 'testing' }
SSWDBOwnedMultiValueCacheDictionarySpec >> hasCollection: updatedCollection anyAdditionsOrRemovalsFrom: originalCollection [

	updatedCollection size ~= originalCollection size ifTrue: [^true].

	updatedCollection keysAndValuesDo: 
		[ :key :values || originalValues |
		originalValues := originalCollection at: key ifAbsent: [^true].
		(values size ~= originalValues size or: [values anySatisfy: [ :val | (originalValues identityIncludes: val) not]]) ifTrue: [^true]].

	^false
]

{ #category : 'helpers' }
SSWDBOwnedMultiValueCacheDictionarySpec >> newCollectionWrapper [

	^SSWDBMultiValueCacheDictionaryWrapper new
]
