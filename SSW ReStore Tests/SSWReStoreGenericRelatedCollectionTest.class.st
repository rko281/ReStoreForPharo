"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreGenericRelatedCollectionTest,
	#superclass : #SSWReStoreGenericCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreGenericRelatedCollectionTest class >> isAbstract [

	^self == SSWReStoreGenericRelatedCollectionTest
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testCheckHasChangedComponentChangeDeeplyFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"A change to a collection's component's component does not mark the owner or collection as changed"
	component deepTest name: changedName.
	self assert: (component deepTest _checkHasChangedIn: reStore).
	self deny: (component _checkHasChangedIn: reStore).
	self deny: (anObject _checkHasChangedIn: reStore).

	"...but does withRelated/DependentComponents"
	self assert: (anObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testCheckHasChangedComponentChangeFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to a collection's component does not mark the owner or collection as changed"
	self assert: (component _checkHasChangedIn: reStore).
	self deny: (anObject _checkHasChangedIn: reStore).

	"...but does withDependent/RelatedComponents"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testCommitComponentChangeDeeplyFrom: anObject [

	| component originalName changedName oldTestObject anObject2 |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Commit of just the owner does not commit the change to the component of the component collection"
	component deepTest name: changedName.
	reStore commit: anObject.

	oldTestObject := testObject.
	self fetchTestObjects.
	anObject == oldTestObject
		ifTrue: [anObject2 := testObject]
		ifFalse: [anObject2 := collection].

	component := collection detect: [ :each | each deepTest name = originalName] ifNone: [nil].
	self assert: component notNil.

	"...but does withRelated/DependentComponents"
	component deepTest name: changedName.
	reStore commit: anObject2 withRelatedComponents.
	self fetchTestObjects.
	self assert: (collection anySatisfy: [ :each | each deepTest ifNil: [false] ifNotNil: [ :dt | dt name = changedName]]).
	self deny: (collection anySatisfy: [ :each | each deepTest ifNil: [false] ifNotNil: [ :dt | dt name = originalName]])
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testCommitComponentChangeFrom: anObject [

	| component originalName changedName oldTestObject anObject2 |

	"Commit of just the owner does not commit the change to the component of the collection"
	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.
	reStore commit: anObject.

	oldTestObject := testObject.
	self fetchTestObjects.
	anObject == oldTestObject
		ifTrue: [anObject2 := testObject]
		ifFalse: [anObject2 := collection].

	component := collection detect: [ :each | each name = originalName].
	self assert: (component name = originalName).

	"...but does withRelated/DependentComponents"
	component name: changedName.
	reStore commit: anObject2 withRelatedComponents.
	self fetchTestObjects.
	self assert: (collection anySatisfy: [ :each | each name = changedName]).
	self deny: (collection anySatisfy: [ :each | each name = originalName]).


]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshComponentChangeDeeplyFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	reStore2 evaluateAsTransaction: [((Test storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refresh: anObject.
	self assert: (component deepTest name = originalName).

	reStore refresh: anObject withRelatedComponents.
	self assert: (component deepTest name = changedName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshComponentChangeFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refresh: anObject.
	self assert: (component name = originalName).

	reStore refresh: anObject withRelatedComponents.
	self assert: (component name = changedName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshComponentChangeIfUpdatedDeeplyFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	reStore2 evaluateAsTransaction: [((Test storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refreshIfUpdated: anObject.
	self assert: (component deepTest name = originalName).

	reStore refreshIfUpdated: anObject withRelatedComponents.
	self assert: (component deepTest name = changedName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshComponentChangeIfUpdatedFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refreshIfUpdated: anObject.
	self assert: (component name = originalName).

	reStore refreshIfUpdated: anObject withRelatedComponents.
	self assert: (component name = changedName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshComponentChangeWithExclusionFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refresh: (anObject withRelatedComponents without: collection).
	self assert: (component name = originalName).

	"Exclusion mechanism does not (currently) apply to components of collections"
	reStore refresh: (anObject withRelatedComponents without: component).
	self assert: (component name = changedName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshRollbackComponentChangeDeeplyFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Refresh of just the owner does not revert the change to the collection"
	component deepTest name: changedName.
	reStore refresh: testObject.
	self assert: (component deepTest name = changedName).

	"...but does withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshRollbackComponentChangeDeeplyIfUpdatedFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Refresh of just the owner does not revert the change to the collection"
	component deepTest name: changedName.
	reStore refreshIfUpdated: testObject.
	self assert: (component deepTest name = changedName).

	"...but does withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshRollbackComponentChangeFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Refresh of just the owner does not revert the change to the collection"
	reStore refresh: anObject.
	self assert: (component name = changedName).

	"...but does withRelated/DependentComponents"
	reStore refresh: anObject withRelatedComponents.
	self assert: (component name = originalName)

]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRefreshRollbackComponentChangeIfUpdatedFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Refresh of just the owner does not revert the change to the collection"
	reStore refreshIfUpdated: anObject.
	self assert: (component name = changedName).

	"...but does withRelated/DependentComponents"
	reStore refreshIfUpdated: anObject withRelatedComponents.
	self assert: (component name = originalName)

]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRollbackComponentChangeDeeplyFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := 'deep test'.
	changedName := originalName, '_changed'.
	reStore evaluateAsTransaction: [component deepTest: (Test new name: originalName; yourself)].

	"Rollback of just the owner does not revert the change to the collection"
	component deepTest name: changedName.
	reStore rollback: testObject.
	self assert: (component deepTest name = changedName).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component deepTest name = originalName)
]

{ #category : #private }
SSWReStoreGenericRelatedCollectionTest >> _testRollbackComponentChangeFrom: anObject [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: anObject.
	self assert: (component name = changedName).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component name = originalName)

]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCheckHasChangedComponentAddition [

	self addToCollection.

	"Addition to a collection does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCheckHasChangedComponentChange [

	self _testCheckHasChangedComponentChangeFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCheckHasChangedComponentChangeDeeply [

	self _testCheckHasChangedComponentChangeDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCheckHasChangedComponentRemoval [

	self removeFromCollection.

	"Removal from a collection does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCheckHasChangedComponentReplace [

	self replaceInCollection.

	"Replacing an element of a collection does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionCheckHasChangedComponentChange [

	self _testCheckHasChangedComponentChangeFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionCheckHasChangedComponentChangeDeeply [

	self _testCheckHasChangedComponentChangeDeeplyFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionCommitComponentChange [

	self _testCommitComponentChangeFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionCommitComponentChangeDeeply [

	self _testCommitComponentChangeDeeplyFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshComponentChange [

	self _testRefreshComponentChangeFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshComponentChangeDeeply [

	self _testRefreshComponentChangeDeeplyFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshComponentChangeIfUpdated [

	self _testRefreshComponentChangeIfUpdatedFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshComponentChangeIfUpdatedDeeply [

	self _testRefreshComponentChangeIfUpdatedDeeplyFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshComponentChangeWithExclusion [

	self _testRefreshComponentChangeWithExclusionFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshRollbackComponentChange [

	self _testRefreshRollbackComponentChangeFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRefreshRollbackComponentChangeDeeply [

	self _testRefreshRollbackComponentChangeDeeplyFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRollbackComponentChange [

	self _testRollbackComponentChangeFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCollectionRollbackComponentChangeDeeply [

	self _testRollbackComponentChangeDeeplyFrom: collection
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCommitComponentAddition [

	| original added |

	"Commit of just the owner does not commit the change to the collection"
	original := collection copy.
	added := self addToCollection.
	reStore commit: testObject.
	self fetchTestObjects.
	self deny: (collection includes: added).
	self assert: (collection = original).

	"...but does withRelatedComponents"
	original := collection copy.
	added := self addToCollection.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (collection includes: added)

]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCommitComponentChange [

	self _testCommitComponentChangeFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCommitComponentChangeDeeply [

	self _testCommitComponentChangeDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testCommitComponentRemoval [

	| originalAndReplacement |

	"Commit of just the owner does not commit the change to the collection"
	originalAndReplacement := self replaceInCollection.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (collection includes: originalAndReplacement key).
	self deny: (collection includes: originalAndReplacement value).

	"...but does withRelatedComponents"
	originalAndReplacement := self replaceInCollection.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self deny: (collection includes: originalAndReplacement key).
	self assert: (collection includes: originalAndReplacement value).

]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentAddition [

	| originalSize added | 

	originalSize := collection size.

	added := self addToCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	reStore refresh: testObject.
	self assert: collection size = originalSize.

	reStore refresh: testObject withRelatedComponents.
	self assert: collection size equals: (originalSize + 1).
	self assert: (collection select: [ :each | each name = added name]) size equals: 1
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentChange [

	self _testRefreshComponentChangeFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentChangeAndRemoval [

	| component originalSize originalName changedName removed | 

	component := collection anyOne.
	originalSize := collection size.
	originalName := component name.

	reStore2 evaluateAsTransaction: 
		[removed := self remove: ((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) fromCollection: testObject2 component.
		changedName := originalName, '_changed'.
		removed name: changedName].

	self refreshDelay.

	"No change without withRelatedComponents"
	reStore refresh: testObject.
	self assert: collection size equals: originalSize.
	self assert: (collection includes: component).
	self assert: component name equals: originalName.

	"Now withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: collection size equals: (originalSize - 1).
	self assert: (collection allSatisfy: [ :each | each name ~= removed name]).
	self deny: (collection includes: component).
	self componentDefinition isValueDependent 
		ifTrue: [self assert: component isDBDeleted]
		ifFalse: [self assert: component name equals: changedName]
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentChangeDeeply [

	self _testRefreshComponentChangeDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentChangeIfUpdated [

	self _testRefreshComponentChangeIfUpdatedFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentChangeIfUpdatedDeeply [

	self _testRefreshComponentChangeIfUpdatedDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentChangeWithExclusion [

	self _testRefreshComponentChangeWithExclusionFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentRemoval [

	| component originalSize originalName changedName removed | 

	component := collection anyOne.
	originalSize := collection size.
	originalName := component name.

	reStore2 evaluateAsTransaction: [removed := self remove: ((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) fromCollection: testObject2 component].
	self refreshDelay.

	changedName := component name, '_changed'.
	component name: changedName.

	"No change without withRelatedComponents"
	reStore refresh: testObject.
	self assert: collection size equals: originalSize.
	self assert: (collection includes: component).
	self assert: component name equals: changedName.

	"Now withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: collection size equals: (originalSize - 1).
	self assert: (collection allSatisfy: [ :each | each name ~= removed name]).
	self deny: (collection includes: component).
	self componentDefinition isValueDependent 
		ifTrue: [self assert: component isDBDeleted]
		ifFalse: [self assert: component name equals: originalName]
]

{ #category : #public }
SSWReStoreGenericRelatedCollectionTest >> testRefreshComponentReplace [

	| originalSize originalAndReplacement original replacement | 

	originalSize := collection size.

	reStore2 evaluateAsTransaction: [originalAndReplacement := self replaceInCollection: (reStore2 instancesOf: testObject class) first component].
	self refreshDelay.

	original := originalAndReplacement key.
	replacement := originalAndReplacement value.

	reStore refresh: testObject.
	self assert: (collection size = originalSize).
	self assert: (collection select: [ :each | each name = original name]) size = 1.
	self assert: (collection select: [ :each | each name = replacement name]) size = 0.

	reStore refresh: testObject withRelatedComponents.
	self assert: (collection size = originalSize).
	self assert: (collection select: [ :each | each name = original name]) size = 0.
	self assert: (collection select: [ :each | each name = replacement name]) size = 1.

]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshIfUpdatedComponentChangeAndRemoval [

	| component originalSize originalName changedName removed | 

	component := collection anyOne.
	originalSize := collection size.
	originalName := component name.

	reStore2 evaluateAsTransaction: 
		[removed := self remove: ((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) fromCollection: testObject2 component.
		changedName := originalName, '_changed'.
		removed name: changedName].

	self refreshDelay.
	
	"No change without withRelatedComponents"
	reStore refreshIfUpdated: testObject.
	self assert: collection size equals: originalSize.
	self assert: (collection includes: component).
	self assert: component name equals: originalName.

	"Now withRelatedComponents"
	reStore refreshIfUpdated: testObject withRelatedComponents.
	self assert: collection size equals: (originalSize - 1).
	self assert: (collection allSatisfy: [ :each | each name ~= removed name]).
	self deny: (collection includes: component).
	self componentDefinition isValueDependent ifFalse: [self assert: component name equals: changedName]
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRefreshesComponentChange [

	| added originalName |

	added := self addToCollection.
	added storeIn: reStore.

	originalName := added name.
	added name: originalName, '_changed'.

	testObject refresh.

	self deny: (collection includes: added).
	self assert: (added name = originalName)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentAddition [

	| original added |

	original := collection copy.
	added := self addToCollection.

	"Refresh of just the owner does not revert the change to the collection"
	reStore refresh: testObject.
	self assert: (collection includes: added).
	self assert: (collection size = (original size + 1)).

	"...but does withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self deny: (collection includes: added).
	self assert: (collection size = original size).

]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentChange [

	self _testRefreshRollbackComponentChangeFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentChangeDeeply [

	self _testRefreshRollbackComponentChangeDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentChangeIfUpdated [

	self _testRefreshComponentChangeIfUpdatedFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentChangeIfUpdatedDeeply [

	self _testRefreshComponentChangeIfUpdatedDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentRemoval [

	| original removed |

	original := collection copy.
	removed := self removeFromCollection.

	"Refresh of just the owner does not revert the change to the collection"
	reStore refresh: testObject.
	self deny: (collection includes: removed).
	self assert: (collection size = (original size - 1)).

	"...but does withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: (collection includes: removed).
	self assert: (collection size = original size)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRefreshRollbackComponentReplace [

	| originalAndReplacement |

	originalAndReplacement := self replaceInCollection.

	"Refresh of just the owner does not revert the change to the collection"
	reStore refresh: testObject.
	self deny: (collection includes: originalAndReplacement key).
	self assert: (collection includes: originalAndReplacement value).

	"...but does withRelatedComponents"
	reStore refresh: testObject withRelatedComponents.
	self assert: (collection includes: originalAndReplacement key).
	self deny: (collection includes: originalAndReplacement value)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRollbackComponentAddition [

	| original added |

	original := collection copy.
	added := self addToCollection.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self assert: (collection includes: added).
	self assert: (collection size = (original size + 1)).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self deny: (collection includes: added).
	self assert: (collection size = original size).

]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRollbackComponentChange [

	self _testRollbackComponentChangeFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRollbackComponentChangeDeeply [

	self _testRollbackComponentChangeDeeplyFrom: testObject
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRollbackComponentRemoval [

	| original removed |

	original := collection copy.
	removed := self removeFromCollection.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self deny: (collection includes: removed).
	self assert: (collection size = (original size - 1)).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (collection includes: removed).
	self assert: (collection size = original size)
]

{ #category : #'unit tests' }
SSWReStoreGenericRelatedCollectionTest >> testRollbackComponentReplace [

	| originalAndReplacement |

	originalAndReplacement := self replaceInCollection.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self deny: (collection includes: originalAndReplacement key).
	self assert: (collection includes: originalAndReplacement value).

	"...but does withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (collection includes: originalAndReplacement key).
	self deny: (collection includes: originalAndReplacement value)
]
