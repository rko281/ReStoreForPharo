"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreNonRelatedDictionaryTest,
	#superclass : #SSWReStoreGenericNonRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreNonRelatedDictionaryTest >> addToCollection: aCollection [

	^aCollection at: self templateComponent put: self templateComponent
]

{ #category : #accessing }
SSWReStoreNonRelatedDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest -> GenericOwnedTest)
]

{ #category : #helpers }
SSWReStoreNonRelatedDictionaryTest >> remove: anObject fromCollection: aCollection [

	^aCollection removeKey: (aCollection keyAtValue: anObject)
]

{ #category : #helpers }
SSWReStoreNonRelatedDictionaryTest >> removeFromCollection: aCollection [

	^aCollection removeKey: collection keys anyOne
]

{ #category : #public }
SSWReStoreNonRelatedDictionaryTest >> replaceInCollection: aCollection [

	| key old |

	key := aCollection keys anyOne.
	old := aCollection at: key.
	^old -> (aCollection at: key put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreNonRelatedDictionaryTest >> templateCollection [

	^Dictionary new
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		yourself
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedDictionaryTest >> testIncludesAssociation [

	| instances existingAssoc template templateKey matches |

	instances := GenericTest storedInstancesIn: reStore.
	existingAssoc := testObject component associations anyOne.
	template := self addToCollection.
	templateKey := testObject component keyAtValue: template.
	self assert: (instances anySatisfy: [ :each | each component includesAssociation: existingAssoc]).
	self deny: (instances anySatisfy: [ :each | each component includesAssociation: (existingAssoc key -> template)]).
	self deny: (instances anySatisfy: [ :each | each component includesAssociation: (templateKey -> existingAssoc value)]).
	self deny: (instances anySatisfy: [ :each | each component includesAssociation: (templateKey -> template)]).

	testObject component removeKey: existingAssoc key.
	testObject store.

	self deny: (instances anySatisfy: [ :each | each component includesAssociation: existingAssoc]).
	self deny: (instances anySatisfy: [ :each | each component includesAssociation: (existingAssoc key -> template)]).
	self deny: (instances anySatisfy: [ :each | each component includesAssociation: (templateKey -> existingAssoc value)]).
	self assert: (instances anySatisfy: [ :each | each component includesAssociation: (templateKey -> template)]).

	matches := instances select: [ :each | each component includesAssociation: (templateKey -> template)].
	self assert: matches size equals: 1.
	self assert: matches first == testObject
]

{ #category : #'unit tests' }
SSWReStoreNonRelatedDictionaryTest >> testIncludesKey [

	| instances existingKey template templateKey matches |

	instances := GenericTest storedInstancesIn: reStore.
	existingKey := testObject component keys anyOne.
	template := self addToCollection.
	templateKey := testObject component keyAtValue: template.
	self assert: (instances anySatisfy: [ :each | each component includesKey: existingKey]).
	self deny: (instances anySatisfy: [ :each | each component includesKey: templateKey]).

	testObject component removeKey: existingKey.
	testObject store.

	self deny: (instances anySatisfy: [ :each | each component includesKey: existingKey]).
	self assert: (instances anySatisfy: [ :each | each component includesKey: templateKey]).

	matches := instances select: [ :each | each component includesKey: templateKey].
	self assert: matches size equals: 1.
	self assert: matches first == testObject
]
