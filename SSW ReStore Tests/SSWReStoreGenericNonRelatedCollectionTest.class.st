"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreGenericNonRelatedCollectionTest,
	#superclass : #SSWReStoreGenericCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreGenericNonRelatedCollectionTest class >> isAbstract [

	^self == SSWReStoreGenericNonRelatedCollectionTest
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCheckHasChangedComponentAddition [

	self addToCollection.

	"Addition to a collection does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents, even when the collection elements are not related"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCheckHasChangedComponentChange [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"A change to a collection's component does not mark the owner or collection as changed"
	self assert: (component _checkHasChangedIn: reStore).
	self deny: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...even withRelatedComponents"
	self deny: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCheckHasChangedComponentRemoval [

	self removeFromCollection.

	"Removal from a collection does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents, even when the collection elements are not related"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCheckHasChangedComponentReplace [

	self replaceInCollection.

	"Replacing an element of a collection does not mark the owner as changed"
	self assert: (collection _checkHasChangedIn: reStore).
	self deny: (testObject _checkHasChangedIn: reStore).

	"...but does withRelatedComponents, even when the collection elements are not related"
	self assert: (testObject withRelatedComponents _checkHasChangedIn: reStore)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCollectionRefreshComponentChange [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refresh: collection.
	self assert: (component name = originalName).

	reStore refresh: collection withComponents.
	self assert: (component name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCollectionRefreshComponentChangeIfUpdated [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refreshIfUpdated: collection.
	self assert: (component name = originalName).

	reStore refreshIfUpdated: collection withComponents.
	self assert: (component name = changedName)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCommitComponentAddition [

	| original added |

	"Commit of just the owner does not commit the addition to the collection"
	original := collection copy.
	added := self addToCollection.
	reStore commit: testObject.
	self fetchTestObjects.
	self deny: (collection includes: added).
	self assert: (collection = original).

	"...but does withRelatedComponents, even when the collection elements are not related"
	original := collection copy.
	added := self addToCollection.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self assert: (collection includes: added).
	self deny: (collection = original).

]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCommitComponentChange [

	| component originalName changedName |

	"Commit of just the owner does not commit the change to the component of the collection"
	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.
	reStore commit: testObject.
	self fetchTestObjects.
	component := collection detect: [ :each | each name = originalName].
	self assert: (component name = originalName).

	"...even withRelatedComponents"
	component name: changedName.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	component := collection detect: [ :each | each name = originalName].
	self assert: (component name = originalName).
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCommitComponentRemoval [

	| removed |

	"Commit of just the owner does not commit the removal from the collection"
	removed := self removeFromCollection.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (collection includes: removed).

	"...but does withRelatedComponents, even when the collection elements are not related"
	removed := self removeFromCollection.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self deny: (collection includes: removed).

]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testCommitComponentReplace [

	| originalAndReplacement |

	"Commit of just the owner does not commit the replacement to the collection"
	originalAndReplacement := self replaceInCollection.
	reStore commit: testObject.
	self fetchTestObjects.
	self assert: (collection includes: originalAndReplacement key).
	self deny: (collection includes: originalAndReplacement value).

	"...but does withRelatedComponents, even when the collection elements are not related"
	originalAndReplacement := self replaceInCollection.
	reStore commit: testObject withRelatedComponents.
	self fetchTestObjects.
	self deny: (collection includes: originalAndReplacement key).
	self assert: (collection includes: originalAndReplacement value).

]

{ #category : #public }
SSWReStoreGenericNonRelatedCollectionTest >> testRefreshComponentAddition [

	| originalSize added | 

	originalSize := collection size.

	added := self addToCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	reStore refresh: testObject.
	self assert: collection size = originalSize.

	reStore refresh: testObject withComponents.
	self assert: collection size equals: (originalSize + 1).
	self assert: (collection select: [ :each | each name = added name]) size equals: 1
]

{ #category : #public }
SSWReStoreGenericNonRelatedCollectionTest >> testRefreshComponentChange [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refresh: testObject.
	self assert: (component name = originalName).

	reStore refresh: testObject withComponents.
	self assert: (component name = changedName)
]

{ #category : #public }
SSWReStoreGenericNonRelatedCollectionTest >> testRefreshComponentChangeIfUpdated [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.

	reStore2 evaluateAsTransaction: [((component class storedInstancesIn: reStore2) detect: [ :each | each name = originalName]) name: changedName].
	self refreshDelay.

	reStore refreshIfUpdated: testObject.
	self assert: (component name = originalName).

	reStore refreshIfUpdated: testObject withComponents.
	self assert: (component name = changedName)
]

{ #category : #public }
SSWReStoreGenericNonRelatedCollectionTest >> testRefreshComponentRemoval [

	| component originalSize removed | 

	component := collection anyOne.
	originalSize := collection size.

	removed := self remove: ((component class storedInstancesIn: reStore2) detect: [ :each | each name = component name]) fromCollection: testObject2 component.
	self assert: testObject2 store.
	self refreshDelay.

	reStore refresh: testObject.
	self assert: collection size equals: originalSize.
	self assert: (self includes: component).

	reStore refresh: testObject withComponents.
	self assert: collection size equals: (originalSize - 1).
	self assert: (self allSatisfy: [ :each | each name ~= removed name]).
	self deny: (self includes: component)
]

{ #category : #public }
SSWReStoreGenericNonRelatedCollectionTest >> testRefreshComponentReplace [

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

	reStore refresh: testObject withComponents.
	self assert: (collection size = originalSize).
	self assert: (collection select: [ :each | each name = original name]) size = 0.
	self assert: (collection select: [ :each | each name = replacement name]) size = 1.

]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testRollbackComponentAddition [

	| original added |

	original := collection copy.
	added := self addToCollection.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self assert: (collection includes: added).
	self assert: (collection size = (original size + 1)).

	"...but does withRelatedComponents, even when the collection elements are not related"
	reStore rollback: testObject withRelatedComponents.
	self deny: (collection includes: added).
	self assert: (collection size = original size)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testRollbackComponentChange [

	| component originalName changedName |

	component := collection anyOne.
	originalName := component name.
	changedName := originalName, '_changed'.
	component name: changedName.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self assert: (component name = changedName).

	"...even withRelatedComponents"
	reStore rollback: testObject withRelatedComponents.
	self assert: (component name = changedName)

]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testRollbackComponentRemoval [

	| original removed |

	original := collection copy.
	removed := self removeFromCollection.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self deny: (collection includes: removed).
	self assert: (collection size = (original size - 1)).

	"...but does withRelatedComponents, even when the collection elements are not related"
	reStore rollback: testObject withRelatedComponents.
	self assert: (collection includes: removed).
	self assert: (collection size = original size)
]

{ #category : #'unit tests' }
SSWReStoreGenericNonRelatedCollectionTest >> testRollbackComponentReplace [

	| originalAndReplacement |

	originalAndReplacement := self replaceInCollection.

	"Rollback of just the owner does not revert the change to the collection"
	reStore rollback: testObject.
	self deny: (collection includes: originalAndReplacement key).
	self assert: (collection includes: originalAndReplacement value).

	"...but does withRelatedComponents, even when the collection elements are not related"
	reStore rollback: testObject withRelatedComponents.
	self assert: (collection includes: originalAndReplacement key).
	self deny: (collection includes: originalAndReplacement value)
]
