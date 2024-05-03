"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRelatedDictionaryTest,
	#superclass : #SSWReStoreGenericRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedDictionaryTest class >> multipleOccurrenceTestSelectors [

	^super multipleOccurrenceTestSelectors, #(#testDuplicateEntries)
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> addToCollection: aCollection [

	^(self addToCollectionAnsweringAssociation: aCollection) value
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> addToCollectionAnsweringAssociation [

	^self addToCollectionAnsweringAssociation: collection
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> addToCollectionAnsweringAssociation: aCollection [

	| newKey |

	newKey := self templateComponent.
	^newKey -> (aCollection at: newKey put: self templateComponent)
	
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> addToCollectionAnsweringKey [

	^self addToCollectionAnsweringAssociation key
]

{ #category : #accessing }
SSWReStoreRelatedDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest -> GenericOwnedTest related)
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> duplicateInCollection: aCollection [

	| keys |

	keys := aCollection keys asArray.
	^aCollection at: keys first put: (aCollection at: keys last)
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> remove: anObject fromCollection: aCollection [

	^aCollection removeKey: (aCollection keyAtValue: anObject)
]

{ #category : #public }
SSWReStoreRelatedDictionaryTest >> replaceInCollection: aCollection [

	| key old |

	key := aCollection keys anyOne.
	old := aCollection at: key.
	^old -> (aCollection at: key put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreRelatedDictionaryTest >> templateCollection [

	^Dictionary new
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		yourself
]

{ #category : #public }
SSWReStoreRelatedDictionaryTest >> testDependencyDeleteOnRepeatedRemoval [

	"Check that non-dependent collection contents are or are not deleted when removed, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not).
	Reimplemented here since we need to deal with the keys"

	| component id cls oldKey newKey |

	component := self anyOne.
	id := component _id.
	cls := component class.

	"Add a second occurrence of component"
	oldKey := collection keyAtValue: component.
	newKey := self templateComponent.
	collection at: newKey put: component.
	testObject store.

	reStore simulateReconnect.
	self fetchTestObjects.
	component := (cls storedInstancesIn: reStore) detect: [ :each | each _id = id] ifNone: [nil].
	self assert: component notNil.
	self assert: (collection occurrencesOf: component) equals: 2.

	"Remove one occurrence of component"
	collection removeKey: oldKey.
	testObject store.

	reStore simulateReconnect.
	self fetchTestObjects.

	"Whether we're dealing with a dependent relationship or not, component should still exist since it is still in the collection"
	component := (cls storedInstancesIn: reStore) detect: [ :each | each _id = id] ifNone: [nil].
	self assert: component notNil.
	self assert: (collection occurrencesOf: component) equals: 1.

	"Remove the remaining occcurrence and test existence depending on dependency"
	self remove: component fromCollection: collection.
	testObject store.

	self _testComponentExistenceOnDependency: component
]

{ #category : #'unit tests' }
SSWReStoreRelatedDictionaryTest >> testDuplicateEntries [

	"Ensure duplicate entries are handled correctly"

	self duplicateInCollection.

	"This should just involve an update of the value of the entry to which the duplicate has been assigned.
	Previously this would update the duplicated entry's key, add a new entry for the original and delete the original entry"
	self assert: (self countQueriesDuring: [testObject store]) equals: (1 "for the update" + (self componentDefinition isValueDependent ifTrue: [1] ifFalse: [0]) "1 for the deletion of the overwritten item (if dependent)")
]

{ #category : #'unit tests' }
SSWReStoreRelatedDictionaryTest >> testIncludesAssociation [

	| instances existingAssoc newAssoc template templateKey matches |

	instances := GenericTest storedInstancesIn: reStore.
	existingAssoc := testObject component associations anyOne.
	newAssoc := self addToCollectionAnsweringAssociation.
	templateKey := newAssoc key.
	template := newAssoc value.
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
SSWReStoreRelatedDictionaryTest >> testIncludesKey [

	| instances existingKey templateKey matches |

	instances := GenericTest storedInstancesIn: reStore.
	existingKey := testObject component keys anyOne.
	templateKey := self addToCollectionAnsweringKey.
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
