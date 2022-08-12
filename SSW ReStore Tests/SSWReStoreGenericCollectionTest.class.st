"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreGenericCollectionTest,
	#superclass : #SSWReStoreGenericTest,
	#instVars : [
		'collection'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #testing }
SSWReStoreGenericCollectionTest class >> isAbstract [

	^self == SSWReStoreGenericCollectionTest
]

{ #category : #accessing }
SSWReStoreGenericCollectionTest class >> multipleOccurrenceTestSelectors [

	"Return the selectors of any tests that depend on the ability to support multiple occurrences of an object in the collection tested by this class"
	^#(#testDependencyDeleteOnRepeatedRemoval)
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> _testComponentExistenceOnDependency: component [

	"Private - No dependency at this level so should still exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) notNil.

	reStore simulateReconnect.
	self assert: ((component class storedInstancesIn: reStore) anySatisfy: [ :each | each name = component name])
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> addToCollection [

	^self addToCollection: collection
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> addToCollection: aCollection [

	^aCollection add: self templateComponent
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> allSatisfy: aBlock [

	^collection allSatisfy: aBlock
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> anyOne [

	^collection anyOne
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> anySatisfy: aBlock [

	^collection anySatisfy: aBlock
]

{ #category : #testing }
SSWReStoreGenericCollectionTest >> componentDefinitionIsDependent [ 

	^self componentDefinition isValueDependent
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> detect: aBlock [

	^collection detect: aBlock
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> detect: aBlock ifNone: absentBlock [

	^collection detect: aBlock ifNone: absentBlock
]

{ #category : #public }
SSWReStoreGenericCollectionTest >> fetchTestObjects [

	super fetchTestObjects.

	collection := testObject component
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> includes: anObject [

	^collection includes: anObject
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> remove: anObject fromCollection: aCollection [

	^aCollection remove: anObject
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> removeFromCollection [

	^self removeFromCollection: collection
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> removeFromCollection: aCollection [

	^self remove: self anyOne fromCollection: aCollection
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> replaceInCollection [

	^self replaceInCollection: collection
]

{ #category : #public }
SSWReStoreGenericCollectionTest >> replaceInCollection: aCollection [

	self subclassResponsibility
]

{ #category : #'collection behavior' }
SSWReStoreGenericCollectionTest >> select: aBlock [

	^collection select: aBlock
]

{ #category : #accessing }
SSWReStoreGenericCollectionTest >> templateCollection [

	^self subclassResponsibility
]

{ #category : #accessing }
SSWReStoreGenericCollectionTest >> templateTestObject [

	^GenericTest new
		component: self templateCollection;
		yourself
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testCollectionMultiAssignmentFailure [

	"Ensure an attemp to assign a collection to more than one persistent object will fail."

	| object1 object2 |

	object1 := self templateTestObject.
	object1 storeIn: reStore.

	object2 := self templateTestObject.
	object2 component: object1 component.

	self should: [object2 storeIn: reStore] raise: Error
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testCollectionRefreshComponentAddition [

	| originalSize added | 

	originalSize := collection size.

	added := self addToCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	collection refresh.
	self assert: collection size equals: (originalSize + 1).
	self assert: (self select: [ :each | each name = added name]) size equals: 1
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testCollectionRefreshComponentRemoval [

	| component originalSize removed | 

	component := self anyOne.
	originalSize := collection size.

	removed := self remove: ((component class storedInstancesIn: reStore2) detect: [ :each | each name = component name]) fromCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	collection refresh.
	self assert: collection size equals: (originalSize - 1).
	self assert: (self allSatisfy: [ :each | each name ~= removed name]).
	self deny: (self includes: component)
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testCollectionRefreshComponentReplace [

	| originalSize originalAndReplacement original replacement | 

	originalSize := collection size.

	originalAndReplacement := self replaceInCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	original := originalAndReplacement key.
	replacement := originalAndReplacement value.

	collection refresh.
	self assert: collection size equals: originalSize.
	self assert: (self select: [ :each | each name = original name]) size equals: 0.
	self assert: (self select: [ :each | each name = replacement name]) size equals: 1

]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testCollectionUninitializedOnRollback [

	"Ensure a collection that was created when storing an object with a collection definition (i.e. the collection inst var was nil prior to the store) is reset to nil on rollback"

	| object |

	object := self templateTestObject.

	reStore beginTransaction.
	object component: nil; storeIn: reStore.
	reStore rollbackTransaction.

	self assert: object component isNil
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testDependencyCascadedDelete [

	"Check that collection contents are or are not deleted when the owning object is deleted, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	| component |

	component := self anyOne.
	testObject unstore.

	"Verify the delete"
	self assert: (testObject class storedInstancesIn: reStore) isEmpty.

	self _testComponentExistenceOnDependency: component
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testDependencyDeleteOnRemoval [

	"Check that non-dependent collection contents are or are not deleted when removed, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	| component |

	component := self anyOne.
	self remove: component fromCollection: collection.

	testObject store.

	self _testComponentExistenceOnDependency: component
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testDependencyDeleteOnRepeatedRemoval [

	"Check that non-dependent collection contents are or are not deleted when removed, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	| component id cls |

	component := collection anyOne.
	id := component _id.
	cls := component class.

	"Add a second occurrence of component"
	collection add: component.
	testObject store.

	reStore simulateReconnect.
	self fetchTestObjects.
	component := (cls storedInstancesIn: reStore) detect: [ :each | each _id = id] ifNone: [nil].
	self assert: component notNil.
	self assert: (collection occurrencesOf: component) equals: 2.

	"Remove one occurrence of component"
	self remove: component fromCollection: collection.
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
SSWReStoreGenericCollectionTest >> testDependencyDeleteOnReplacement [

	"Check that non-dependent collection contents are or are not deleted when replaced, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	| originalAndReplacement |

	reStore evaluateAsTransaction: [originalAndReplacement := self replaceInCollection].

	self componentDefinitionIsDependent ifTrue: [self _testComponentExistenceOnDependency: originalAndReplacement key]
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testIncludes [

	| instances existing template matches |

	instances := GenericTest storedInstancesIn: reStore.
	existing := testObject component anyOne.
	template := self addToCollection.
	self assert: (instances anySatisfy: [ :each | each component includes: existing]).
	self deny: (instances anySatisfy: [ :each | each component includes: template]).

	self remove: existing fromCollection: testObject component.
	testObject store.

	self deny: (instances anySatisfy: [ :each | each component includes: existing]).
	self assert: (instances anySatisfy: [ :each | each component includes: template]).

	matches := instances select: [ :each | each component includes: template].
	self assert: matches size equals: 1.
	self assert: matches first == testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testNewEmptyCollectionRollback [

	"Ensure a collection that is stored when empty can be subsequently rolled back without error (previously gave an error for non-owned collections)"

	| object |

	object := self templateTestObject.
	object component removeAll.
	object storeIn: reStore.

	reStore beginTransaction.
	self addToCollection: object component.
	self assert: object component size equals: 1.
	self shouldnt: [reStore rollbackTransaction] raise: Error.
	self assert: object component size equals: 0
]
