"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRelatedKeyDictionaryTest,
	#superclass : #SSWReStoreRelatedDictionaryTest,
	#instVars : [
		'inverseDictionary'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreRelatedKeyDictionaryTest >> addToCollection: aCollection [

	"We're interested in the key"

	^(self addToCollectionAnsweringAssociation: aCollection) key
]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> allSatisfy: aBlock [

	collection keysDo: [ :each | (aBlock value: each) ifFalse: [^false]].

	^true
]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> anyOne [

	^collection keysDo: [ :key | ^key]
]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> anySatisfy: aBlock [

	collection keysDo: [ :each | (aBlock value: each) ifTrue: [^true]].

	^false
]

{ #category : #accessing }
SSWReStoreRelatedKeyDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest related -> GenericOwnedTest)
]

{ #category : #testing }
SSWReStoreRelatedKeyDictionaryTest >> componentDefinitionIsDependent [

	"We're interested in the key"

	^self componentDefinition isKeyDependent
]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> detect: aBlock [

	^self detect: aBlock ifNone: [self error: 'not found']

]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> detect: aBlock ifNone: absentBlock [

	collection keysDo: [ :each | (aBlock value: each) ifTrue: [^each]].

	^absentBlock value
]

{ #category : #public }
SSWReStoreRelatedKeyDictionaryTest >> fetchTestObjects [

	super fetchTestObjects.

	inverseDictionary := IdentityDictionary new.

	testObject component keysAndValuesDo: [ :eachKey :eachValue | inverseDictionary at: eachValue put: eachKey]
]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> includes: anObject [

	^(collection includesKey: anObject) or: 
		"For the benefit of tests which change anObject such that its hash changes"
		[collection keysDo: [ :each | each == anObject ifTrue: [^true]].
		false]
]

{ #category : #helpers }
SSWReStoreRelatedKeyDictionaryTest >> remove: anObject fromCollection: aCollection [

	aCollection removeKey: anObject.
	^anObject
]

{ #category : #helpers }
SSWReStoreRelatedKeyDictionaryTest >> replaceInCollection: aCollection [

	"We need to replace a key, not a value"

	| oldKey newKey |

	oldKey := aCollection keys anyOne.
	newKey := self templateComponent.
	aCollection at: newKey put: (aCollection removeKey: oldKey).
	^oldKey -> newKey
]

{ #category : #'collection behavior' }
SSWReStoreRelatedKeyDictionaryTest >> select: aBlock [

	^collection keys select: aBlock
]

{ #category : #'unit tests' }
SSWReStoreRelatedKeyDictionaryTest >> testDependencyDeleteOnRepeatedRemoval [

	"Check that non-dependent collection contents are or are not deleted when removed, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)."

	"Not an appropriate test here since each key can only exist in the collection once"
]

{ #category : #'unit tests' }
SSWReStoreRelatedKeyDictionaryTest >> testIncludes [

	| instances existing template matches |

	instances := GenericTest storedInstancesIn: reStore.
	existing := self anyOne.
	template := self addToCollection.
	self assert: (instances anySatisfy: [ :each | each component includesKey: existing]).
	self deny: (instances anySatisfy: [ :each | each component includesKey: template]).

	self remove: existing fromCollection: testObject component.
	testObject store.

	self deny: (instances anySatisfy: [ :each | each component includesKey: existing]).
	self assert: (instances anySatisfy: [ :each | each component includesKey: template]).

	matches := instances select: [ :each | each component includesKey: template].
	self assert: matches size equals: 1.
	self assert: matches first == testObject
]
