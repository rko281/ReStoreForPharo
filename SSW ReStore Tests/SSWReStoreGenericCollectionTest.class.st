"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreGenericCollectionTest,
	#superclass : #SSWReStoreGenericTest,
	#instVars : [
		'collection'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
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

{ #category : #public }
SSWReStoreGenericCollectionTest >> fetchTestObjects [

	super fetchTestObjects.

	collection := testObject component
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

	^self remove: aCollection anyOne fromCollection: aCollection
]

{ #category : #helpers }
SSWReStoreGenericCollectionTest >> replaceInCollection [

	^self replaceInCollection: collection
]

{ #category : #public }
SSWReStoreGenericCollectionTest >> replaceInCollection: aCollection [

	self subclassResponsibility
]

{ #category : #accessing }
SSWReStoreGenericCollectionTest >> templateCollection [

	^self subclassResponsibility
]

{ #category : #accessing }
SSWReStoreGenericCollectionTest >> templateComponent [

	"Ensure unique name"
	(Delay forMicroseconds: 10) wait.

	^GenericOwnedTest new name: (self class name, Time microsecondClockValue printString)
]

{ #category : #accessing }
SSWReStoreGenericCollectionTest >> templateTestObject [

	^GenericTest new
		component: self templateCollection;
		yourself
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
	self assert: (collection select: [ :each | each name = added name]) size equals: 1
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testCollectionRefreshComponentRemoval [

	| component originalSize removed | 

	component := collection anyOne.
	originalSize := collection size.

	removed := self remove: ((component class storedInstancesIn: reStore2) detect: [ :each | each name = component name]) fromCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	collection refresh.
	self assert: collection size equals: (originalSize - 1).
	self assert: (collection allSatisfy: [ :each | each name ~= removed name]).
	self deny: (collection includes: component)
]

{ #category : #public }
SSWReStoreGenericCollectionTest >> testCollectionRefreshComponentReplace [

	| originalSize originalAndReplacement original replacement | 

	originalSize := collection size.

	reStore2 evaluateAsTransaction: [originalAndReplacement := self replaceInCollection: (reStore2 instancesOf: testObject class) first component].
	self refreshDelay.

	original := originalAndReplacement key.
	replacement := originalAndReplacement value.

	collection refresh.
	self assert: (collection size = originalSize).
	self assert: (collection select: [ :each | each name = original name]) size = 0.
	self assert: (collection select: [ :each | each name = replacement name]) size = 1.

]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testDependencyCascadedDelete [

	"Check that collection contents are or are not deleted when the owning object is deleted, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	| component |

	component := collection anyOne.
	testObject unstore.

	"Verify the delete"
	self assert: (testObject class storedInstancesIn: reStore) isEmpty.

	self _testComponentExistenceOnDependency: component
]

{ #category : #'unit tests' }
SSWReStoreGenericCollectionTest >> testDependencyDeleteOnRemoval [

	"Check that non-dependent collection contents are or are not deleted when removed, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	| component |

	component := collection anyOne.
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

	self componentDefinition isValueDependent ifTrue: [self _testComponentExistenceOnDependency: originalAndReplacement key]
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
